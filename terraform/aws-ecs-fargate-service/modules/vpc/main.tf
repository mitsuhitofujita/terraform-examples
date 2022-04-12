resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

#
# internet gateway
#

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.name_prefix
  }
}

#
# route table
#

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name_prefix}-public"
  }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
}

#
# public subnet a
#

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.a_availability_zone // "ap-northeast-1a"
  cidr_block        = var.public_a_cidr_block // "10.0.1.0/24"
  tags = {
    Name = "${var.name_prefix}-public-a"
  }
}

resource "aws_eip" "public_a" {
  vpc = true
  tags = {
    Name = "${var.name_prefix}-public-a"
  }
}

resource "aws_nat_gateway" "public_a" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.public_a.id
  tags = {
    Name = "${var.name_prefix}-public-a"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

#
# public subnet c
#

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.c_availability_zone // "ap-northeast-1c"
  cidr_block        = var.public_c_cidr_block // "10.0.2.0/24"
  tags = {
    Name = "${var.name_prefix}-public-c"
  }
}

resource "aws_eip" "public_c" {
  vpc = true
  tags = {
    Name = "${var.name_prefix}-public-c"
  }
}

resource "aws_nat_gateway" "public_c" {
  subnet_id     = aws_subnet.public_c.id
  allocation_id = aws_eip.public_c.id
  tags = {
    Name = "${var.name_prefix}-public-c"
  }
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

#
# private subnet a
#

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.a_availability_zone  // "ap-northeast-1a"
  cidr_block        = var.private_a_cidr_block // "10.0.11.0/24"
  tags = {
    Name = "${var.name_prefix}-private-a"
  }
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name_prefix}-private-a"
  }
}

resource "aws_route" "private_a" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_a.id
  nat_gateway_id         = aws_nat_gateway.public_a.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

#
# private subnet c
#

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.c_availability_zone  // "ap-northeast-1c"
  cidr_block        = var.private_c_cidr_block // "10.0.12.0/24"
  tags = {
    Name = "${var.name_prefix}-private-c"
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name_prefix}-private-c"
  }
}

resource "aws_route" "private_c" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_c.id
  nat_gateway_id         = aws_nat_gateway.public_c.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_c.id
}

#
# vpc endpoint
#

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_security_group" "vpc_endpoint" {
  name   = "${var.name_prefix}-vpc-endpoint"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_a.cidr_block,
      aws_subnet.private_c.cidr_block
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private_a.id,
    aws_route_table.private_c.id,
  ]
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
  ]
  security_group_ids = [aws_security_group.vpc_endpoint.id]
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
  ]
  security_group_ids = [aws_security_group.vpc_endpoint.id]
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
  ]
  security_group_ids = [aws_security_group.vpc_endpoint.id]
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
  ]
  security_group_ids = [aws_security_group.vpc_endpoint.id]
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
  ]
  security_group_ids = [aws_security_group.vpc_endpoint.id]
}
