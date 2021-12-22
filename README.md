# Packer AMI with Vault 
----------------

This repo builds a vault AMI in AWS

## Install Packer 
-----------------

To install packer, please visit: https://www.packer.io/docs/installation.html

## General Packer Information 
-----------------
You can validate a packer template by running
```
packer validate server.pkr.hcl
```

## Create an Amazon Machine Image (EBS)
In AWS, you will do well to export your access keys --
```
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXX
```
before Running the build command 
```
packer build -var-file=variable.hcl server.hcl
```
where `variable.hcl` is a file that contains variables to be used in the template 
and `server.hcl` is the packer template with build instructions

If your build is successful, console output will look like ...
```
Build 'amazon-ebs' finished.
==> Builds finished. The artifacts of successful builds are:  

--> amazon-ebs: AMIs were created:
us-east-1: ami-0e16831fd87c246ee
```