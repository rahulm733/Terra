
resource "aws_vpc" "main2" {
  cidr_block       = var.vpc2_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.vpc2_name}"
  }
}

resource "aws_flow_log" "VPC2_Flow_Log" {
  iam_role_arn    = aws_iam_role.FlowLog.arn
  log_destination = aws_cloudwatch_log_group.VPC2_Log_Group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main2.id

  tags = {
    Name = "${var.vpc2_name}-FlowLog"
  }
}

resource "aws_cloudwatch_log_group" "VPC2_Log_Group" {
  name = "${var.vpc2_name}-LogGroup"
}

resource "aws_subnet" "PVsubnets2" {
  count      = length(var.vpc2_PVazs)
  vpc_id     = aws_vpc.main2.id
  cidr_block = element(var.vpc2_PVsubnet, count.index)
  availability_zone = element(var.vpc2_PVazs,count.index)

  tags = {
    Name = "${var.vpc2_name}-PV-${count.index + 1}"
  }
}

resource "aws_subnet" "PBsubnets2" {
  count      = length(var.vpc2_PBazs)
  vpc_id     = aws_vpc.main2.id
  cidr_block = element(var.vpc2_PBsubnet, count.index)
  availability_zone = element(var.vpc2_PBazs,count.index)

  tags = {
    Name = "${var.vpc2_name}-PB-${count.index + 1}"
  }
}

resource "aws_route_table" "PVRT2" {
  vpc_id = aws_vpc.main2.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TRANSIT-POC.id

  }
  tags = {
    Name = "${var.vpc2_name}-PVRT"
  }
}

resource "aws_route_table" "PBRT2" {
  vpc_id = aws_vpc.main2.id
  tags = {
    Name = "${var.vpc2_name}-PBRT"
  }
}

resource "aws_route_table_association" "PVRT2" {
  count          = length(var.vpc2_PVazs)
  subnet_id      = aws_subnet.PVsubnets2[count.index].id
  route_table_id = aws_route_table.PVRT2.id
}

resource "aws_route_table_association" "PBRT2" {
  count          = length(var.vpc2_PBazs)
  subnet_id      = aws_subnet.PBsubnets2[count.index].id
  route_table_id = aws_route_table.PBRT2.id
}

resource "aws_security_group" "SG2" {
  name        = "${var.vpc2_name}-DEFAULT-SG"
  description = "${var.vpc2_name}-DEFAULT-SG"
  vpc_id      = aws_vpc.main2.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.vpc2_name}-DEFAULT-SG"
  }
}



resource "aws_ec2_transit_gateway_vpc_attachment" "TRANSIT-POC-Attachment2" {
  count              = 1
  subnet_ids         = [aws_subnet.PVsubnets2[count.index].id]
  transit_gateway_id = aws_ec2_transit_gateway.TRANSIT-POC.id
  vpc_id             = aws_vpc.main2.id

  tags = {
    Name = "${var.vpc2_name}-TRANSIT-Attachment"
  }
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_route_table_association" "TRANSIT-POC-Association2" {

  count                          = 1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TRANSIT-POC-Attachment2[count.index].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TRANSIT-POC-RT.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "TRANSIT-POC-Propagation2" {

  count                          = 1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TRANSIT-POC-Attachment2[count.index].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TRANSIT-POC-RT.id
}

