terraform {
  required_providers {
    aws = {
      version = ">= 4.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "this" {
  name = "geth-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "log_retention" {
  statement {
    actions   = ["logs:PutRetentionPolicy"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "this" {
  name   = "log-retention"
  path   = "/"
  policy = data.aws_iam_policy_document.log_retention.json
}

resource "aws_iam_role_policy_attachment" "log_retention" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "this" {
  name = "geth-instance-profile"
  role = aws_iam_role.this.name
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.cloudwatch_logs_group_name
  skip_destroy      = false
  retention_in_days = 3
}

module "geth_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.17.0"

  name        = "geth-sg"
  description = "Security group for Geth nodes"
  vpc_id      = "vpc-04a4b25dd7833470f"

  ingress_with_cidr_blocks = [
    {
      from_port   = 30303
      to_port     = 30303
      protocol    = "tcp"
      description = "P2P"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 30303
      to_port     = 30303
      protocol    = "udp"
      description = "P2P"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9900
      to_port     = 9900
      protocol    = "tcp"
      description = "gRPC"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9091
      to_port     = 9091
      protocol    = "tcp"
      description = "gRPC Web"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 26657
      to_port     = 26657
      protocol    = "tcp"
      description = "RPC"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 26656
      to_port     = 26656
      protocol    = "tcp"
      description = "P2P"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 26660
      to_port     = 26660
      protocol    = "tcp"
      description = "Prometheus"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 6060
      to_port     = 6060
      protocol    = "tcp"
      description = "pprof"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_rules = ["all-all"]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "node" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.this.name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [module.geth_sg.security_group_id]
  key_name                    = "geth"
  user_data                   = templatefile("${path.module}/userdata.tftpl", { cloudwatch_logs_group_name = var.cloudwatch_logs_group_name })

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdf"
    iops                  = 10000
    volume_size           = 2000
    volume_type           = "gp3"
  }

  tags = {
    Name = "geth-node"
  }
}
