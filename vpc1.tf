terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

resource "aws_vpc" "main1" {
  cidr_block       = var.vpc1_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.vpc1_name}"
  }
}

resource "aws_flow_log" "VPC1_Flow_Log" {
  iam_role_arn    = aws_iam_role.FlowLog.arn
  log_destination = aws_cloudwatch_log_group.VPC1_Log_Group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main1.id

  tags = {
    Name = "${var.vpc1_name}-FlowLog"
  }
}

resource "aws_cloudwatch_log_group" "VPC1_Log_Group" {
  name = "${var.vpc1_name}-LogGroup"
}

resource "aws_iam_role" "FlowLog" {
  name = "FlowLog"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "FlowLogPolicy" {
  name = "FlowLogPolicy"
  role = aws_iam_role.FlowLog.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_subnet" "PVsubnets1" {
  count      = length(var.vpc1_PVazs)
  vpc_id     = aws_vpc.main1.id
  cidr_block = element(var.vpc1_PVsubnet, count.index)
  availability_zone = element(var.vpc1_PVazs,count.index)

  tags = {
    Name = "${var.vpc1_name}-PV-${count.index + 1}"
  }
}

resource "aws_subnet" "PBsubnets1" {
  count      = length(var.vpc1_PBazs)
  vpc_id     = aws_vpc.main1.id
  cidr_block = element(var.vpc1_PBsubnet, count.index)
  availability_zone = element(var.vpc1_PBazs,count.index)

  tags = {
    Name = "${var.vpc1_name}-PB-${count.index + 1}"
  }
}

resource "aws_route_table" "PVRT1" {
  vpc_id = aws_vpc.main1.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TRANSIT-POC.id

  }
  tags = {
    Name = "${var.vpc1_name}-PVRT"
  }
}

resource "aws_route_table" "PBRT1" {
  vpc_id = aws_vpc.main1.id
  tags = {
    Name = "${var.vpc1_name}-PBRT"
  }
}

resource "aws_route_table_association" "PVRT1" {
  count          = length(var.vpc1_PVazs)
  subnet_id      = aws_subnet.PVsubnets1[count.index].id
  route_table_id = aws_route_table.PVRT1.id
}

resource "aws_route_table_association" "PBRT1" {
  count          = length(var.vpc1_PBazs)
  subnet_id      = aws_subnet.PBsubnets1[count.index].id
  route_table_id = aws_route_table.PBRT1.id
}

resource "aws_security_group" "SG1" {
  name        = "${var.vpc1_name}-DEFAULT-SG"
  description = "${var.vpc1_name}-DEFAULT-SG"
  vpc_id      = aws_vpc.main1.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.vpc1_name}-DEFAULT-SG"
  }
}


resource "aws_ec2_transit_gateway" "TRANSIT-POC" {

  tags = {
    Name = "TRANSIT-POC"
  }
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
}

resource "aws_ec2_transit_gateway_route_table" "TRANSIT-POC-RT" {
  transit_gateway_id = aws_ec2_transit_gateway.TRANSIT-POC.id

  tags = {
    Name = "TRANSIT-POC-RT"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "TRANSIT-POC-Attachment1" {
  count              = 1
  subnet_ids         = [aws_subnet.PVsubnets1[count.index].id]
  transit_gateway_id = aws_ec2_transit_gateway.TRANSIT-POC.id
  vpc_id             = aws_vpc.main1.id

  tags = {
    Name = "${var.vpc1_name}-TRANSIT-Attachment"
  }
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_route_table_association" "TRANSIT-POC-Association1" {

  count                          = 1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TRANSIT-POC-Attachment1[count.index].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TRANSIT-POC-RT.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "TRANSIT-POC-Propagation1" {

  count                          = 1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TRANSIT-POC-Attachment1[count.index].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TRANSIT-POC-RT.id
}
