variable "vault_version" {
    type = string
    default = env("VAULT_VERSION")
}
variable "terraform_version" {
    type = string
    default = env("TERRAFORM_VERSION")
}

variable "ami_user" {
    type = string
    description = "AWS Account owner"
}

variable "instance_type" {
    type = string
    description = "Instance type of the EC2 instance on spin  up"
}

// variable "kms_key_id" {
//     type = string
//     description = "kms encryption key ID"
// }

variable "region" {
    type = string 
    default = "us-east-1"
}

variable "source_commit_author" {
    type = string
    description = "Commit Author could be consumed from pipeline environmental variables or hardcoded"
    default = "Gastro.Gee"
}

variable "source_ami_type" {
    type = string
    default = "amzn2-ami-hvm-*-x86_64-gp2"
}

variable "source_root_device_type" {
    default = "ebs"
}

variable "source_virtualization_type" {
    default = "hvm"
}

variable "ssh_user" {
    default = "ec2-user"
}

variable "subnet_id" {
    type = string 
    description = "Subnet ID to be spun up with"
}

variable "vpc_id" {
    type = string
    description = "VPC ID to be spun in"
}

source "amazon-ebs" "vault" {
    ami_name    = "packer-vault-${ formatdate("YYYY-MM-DD'T'hh-mm-ssZ", timestamp()) }"
    ami_regions = ["us-east-1"]
    ami_users   = [var.ami_user]
    encrypt_boot    = false
    instance_type   = var.instance_type

#    kms_key_id  = var.kms_key_id
    region  = var.region
    run_tags = {
        env = "amis"
        owner = var.source_commit_author
        service = "packer"
        source_repo = "packer-aws-vault"
    }
    snapshot_tags = {
        service = "packer"
    }
    source_ami_filter {
        filters = {
            name = var.source_ami_type
            root-device-type = var.source_root_device_type
            virtualization-type = var.source_virtualization_type
        }
        most_recent = true
        owners      = ["amazon"]
    }
    ssh_username = var.ssh_user
    subnet_id = var.subnet_id
    tags = {
        env = "amis"
        owner = var.source_commit_author
        service = "packer"
        vault_version = var.vault_version
    }
    vpc_id  = var.vpc_id
    temporary_iam_instance_profile_policy_document {
        Statement {
            Action   = [
                "ec2:*",
                "iam:PassRole",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetRole",
                "iam:GetInstanceProfile",
                "iam:DeleteRolePolicy",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:PutRolePolicy",
                "iam:AddRoleToInstanceProfile"
                ]
            Effect   = "Allow"
            Resource = ["*"]
            }
        Version = "2012-10-17"
    }
}

build {
    sources = ["source.amazon-ebs.vault"]

    provisioner "shell" {
        inline      = ["echo 'Amazon AMI Build for vault service starting' "]
    }

    provisioner "file" {
        destination = "/home/ec2-user/"
        source      = "ansible/config/ansible.cfg"
    }

    provisioner "shell" {
        inline = [ "mkdir /home/ec2-user/scripts" ]
    }

    ### Temporary move files to user directory to be moved to a more permanent destination later   
    provisioner "file" {
        source = "ansible/config/vault_startup.sh"
        destination = "/home/ec2-user/scripts/"
        direction = "upload"
    }
    provisioner "file" {
        source = "ansible/config/vault_startup.service"
        destination = "/home/ec2-user/scripts/"
        direction = "upload"
    }

    provisioner "shell" {
        inline = [
            "sudo yum -y install jq gcc python3 python3-pip python3-virtualenv",
            "sudo pip3 install 'ansible==3.4.0' pytest testinfra==3.2.0 netaddr",
            "sudo pip3 install hvac python-consul boto3 awscli six requests",
            "sudo yum -y install perl",
            "sudo ln -sf /usr/bin/aws /usr/local/bin/aws",
            "sudo yum -y erase nfs-utils rpcbind", #security-liabilities
            "sudo yum update -y --security --exclude=kernel"
        ]
    }

    provisioner "shell" {
        inline = [
            "sudo mkdir -p /opt/vault/bin",
            "sudo mv /home/ec2-user/scripts/vault_startup.sh /opt/vault/bin/",
            "sudo chmod 0755 /opt/vault/bin/vault_startup.sh",
            "sudo mv /home/ec2-user/scripts/vault_startup.service /etc/systemd/system/vault_startup.service",
            "sudo systemctl daemon-reload",
            "sudo systemctl enable vault_startup"
        ]
        remote_folder = "/home/ec2-user"
    }

    provisioner "shell" {
        inline  = [
            "sudo mkdir -p /opt/packer/ansible/roles/vault",
            "sudo mkdir -p /opt/packer/terraform/vault-configuration-bootstrap",
            "sudo chown -R ec2-user /opt/packer",

        ]
    }

    provisioner "file" {
        destination = "/opt/packer/ansible/"
        source  = "ansible/build/"
    }

    provisioner "ansible-local" {
        playbook_file   = "ansible/build/vault-provisioner.yml"
        staging_directory = "/opt/packer/ansible"
    }

    provisioner "file" {
        destination = "/opt/packer/ansible/vault.yml"
        direction  = "upload"
        source      = "ansible/run/vault.yml"
    }

    provisioner "file" {
        destination = "/opt/packer/ansible/roles/vault"
        direction  = "upload"
        source      = "ansible/run/roles/vault"
    }

    provisioner "file" {
        destination = "/opt/packer/terraform/vault-configuration-bootstrap"
        direction = "upload"
        source = "ansible/terraform"
    }

    provisioner "shell" {
        inline  = ["sudo terraform init -backend=false -get=true -upgrade=true"]
        remote_folder = "/opt/packer/terraform/vault-configuration-bootstrap/terraform"
    }

    post-processor "manifest" {
        output = "manifest.json"
        strip_path = true
    }

}