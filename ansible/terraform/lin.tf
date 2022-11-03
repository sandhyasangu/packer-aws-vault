
data "aws_ami" "rhel" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module amis {
  source  = "mamemomonga/linux-ami/aws"
}

resource "aws_instance" "web" {
  ami           = module.amis.debian.10.amd64
  instance_type = "t3.micro"

  tags = {
    owner = ".com"
    env = "dev"
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_cloudwatch" {
  role       = aws_iam_role.access_ec2_rds.name
  policy_arn = aws_iam_policy.access_ec2_rds.arn
}

resource "aws_iam_role" "access_ec2_rds" {
  name_prefix        = "access-ec2-rds"
  assume_role_policy = data.aws_iam_policy_document.access_ec2_rds.json
}

data "aws_iam_policy_document" "access_ec2_rds" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "access_ec2_rds" {`
#  data.aws_iam_policy_document.mwaa.json
  policy = data.aws_iam_policy_document.access_ec2_rds.json
  role   = aws_iam_role.access_ec2_rds.id
}

resource "aws_iam_user" "mammal_dev" {
  name = ".com"
}

resource "aws_iam_role_policy_attachment" "ec2_rds_access" {
  role       = aws_iam_role.access_ec2_rds.name
  policy_arn = aws_iam_policy.access_ec2_rds.arn
}

resource "aws_iam_role_policy_attachment" "ec2_access_policy" {
  role       = aws_iam_role.access_ec2_rds.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}


resource "aws_iam_role_policy_attachment" "rds_full_access" {
  role       = aws_iam_role.access_ec2_rds.name
  policy_arn ="arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}
