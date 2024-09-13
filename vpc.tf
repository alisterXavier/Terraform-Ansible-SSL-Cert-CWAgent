resource "aws_vpc" "CloudOpsBlend" {
  cidr_block = "10.0.0.0/20"
}

resource "aws_subnet" "public_subnets" {
  count      = length(local.public_subnets)
  cidr_block = local.public_subnets[count.index].cidr_block
  vpc_id     = aws_vpc.CloudOpsBlend.id
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.CloudOpsBlend.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.CloudOpsBlend.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}
resource "aws_route_table_association" "route_table_association" {
  count          = length(aws_subnet.public_subnets)
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}
resource "aws_security_group" "security_group" {
  name   = "InstanceSG"
  vpc_id = aws_vpc.CloudOpsBlend.id
  ingress {
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
  egress {
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
  egress {
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
  egress {
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
}
resource "aws_network_acl" "network_acl" {
  vpc_id     = aws_vpc.CloudOpsBlend.id
  subnet_ids = [aws_subnet.public_subnets[1].id]
  ingress {
    rule_no    = 100
    from_port  = 22
    to_port    = 22
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }
  ingress {
    rule_no    = 110
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }
  ingress {
    rule_no    = 120
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }
  ingress {
    rule_no    = 130
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }
  egress {
    rule_no    = 100
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }
  egress {
    rule_no    = 110
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }
  egress {
    rule_no    = 120
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    action     = "allow"
  }
  # egress {
  #   rule_no    = 130
  #   from_port  = 22
  #   to_port    = 22
  #   cidr_block = "0.0.0.0/0"
  #   protocol   = "tcp"
  #   action     = "allow"
  # }
}