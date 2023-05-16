# Validation Cloud Tech Challenge

![Architecture](/images/geth_node.pdf)

## Introduction
This repository contains code that will create infrastructure for running a Geth node in AWS.

## Prerequisites
The following must be installed in order to run and use the content in this repository:
* [Terraform](https://www.terraform.io/)
* [Golang](https://go.dev/)
* [AWS CLI](https://aws.amazon.com/cli/)
* An AWS account that you own

### IAM Permissions
You must have an IAM user that you are able to authenticate with from your local machine. The following permissions are needed to deploy the infrastructure:
* AmazonEC2FullAccess
* AWSGrafanaAccountAdministrator
* AWSGrafanaWorkspacePermissionManagement
* CloudWatchLogsFullAccess
* IAMFullAccess
* Inline Policy called `sso`:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "sso:CreateManagedApplicationInstance",
                "sso:DeleteManagedApplicationInstance"
            ],
            "Resource": "*"
        }
    ]
}
```

* Inline Policy called `ssm`:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ssm:StartSession",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Name": "geth-node"
                }
            }
        }
    ]
}
```
