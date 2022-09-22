
resource "aws_vpc" "main3" {
  cidr_block       = var.vpc3_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.vpc3_name}"
  }
}

resource "aws_flow_log" "VPC3_Flow_Log" {
  iam_role_arn    = aws_iam_role.FlowLog.arn
  log_destination = aws_cloudwatch_log_group.VPC3_Log_Group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main3.id

  tags = {
    Name = "${var.vpc3_name}-FlowLog"
  }
}

resource "aws_cloudwatch_log_group" "VPC3_Log_Group" {
  name = "${var.vpc3_name}-LogGroup"
}

resource "aws_subnet" "PVsubnets3" {
  count      = length(var.vpc3_PVazs)
  vpc_id     = aws_vpc.main3.id
  cidr_block = element(var.vpc3_PVsubnet, count.index)
  availability_zone = element(var.vpc3_PVazs,count.index)

  tags = {
    Name = "${var.vpc3_name}-PV-${count.index + 1}"
  }
}

resource "aws_subnet" "PBsubnets3" {
  count      = length(var.vpc3_PBazs)
  vpc_id     = aws_vpc.main3.id
  cidr_block = element(var.vpc3_PBsubnet, count.index)
  availability_zone = element(var.vpc3_PBazs,count.index)

  tags = {
    Name = "${var.vpc3_name}-PB-${count.index + 1}"
  }
}

resource "aws_route_table" "PVRT3" {
  vpc_id = aws_vpc.main3.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TRANSIT-POC.id

  }
  tags = {
    Name = "${var.vpc3_name}-PVRT"
  }
}

resource "aws_route_table" "PBRT3" {
  vpc_id = aws_vpc.main3.id
  tags = {
    Name = "${var.vpc3_name}-PBRT"
  }
}

resource "aws_route_table_association" "PVRT3" {
  count          = length(var.vpc3_PVazs)
  subnet_id      = aws_subnet.PVsubnets3[count.index].id
  route_table_id = aws_route_table.PVRT3.id
}

resource "aws_route_table_association" "PBRT3" {
  count          = length(var.vpc3_PBazs)
  subnet_id      = aws_subnet.PBsubnets3[count.index].id
  route_table_id = aws_route_table.PBRT3.id
}

resource "aws_security_group" "SG3" {
  name        = "${var.vpc3_name}-DEFAULT-SG"
  description = "${var.vpc3_name}-DEFAULT-SG"
  vpc_id      = aws_vpc.main3.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.vpc3_name}-DEFAULT-SG"
  }
}



resource "aws_ec2_transit_gateway_vpc_attachment" "TRANSIT-POC-Attachment3" {
  count              = 1
  subnet_ids         = [aws_subnet.PVsubnets3[count.index].id]
  transit_gateway_id = aws_ec2_transit_gateway.TRANSIT-POC.id
  vpc_id             = aws_vpc.main3.id

  tags = {
    Name = "${var.vpc3_name}-TRANSIT-Attachment"
  }
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_route_table_association" "TRANSIT-POC-Association3" {

  count                          = 1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TRANSIT-POC-Attachment3[count.index].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TRANSIT-POC-RT.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "TRANSIT-POC-Propagation3" {

  count                          = 1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TRANSIT-POC-Attachment3[count.index].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TRANSIT-POC-RT.id
}

