provider "aws" {
  region = var.region #"us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  default_tags = merge(
    var.default_tags,
    { "Env" = var.env }
  )
  name_prefix = "${var.prefix}-${var.env}"
}

resource "aws_vpc" "main_cidr" {
  cidr_block           = var.vpc
  instance_tenancy     = "default"
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-vpc"
    }
  )
}





resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_cidr)
  vpc_id                  = aws_vpc.main_cidr.id
  cidr_block              = var.public_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
    }
  )
}


# Add provisioning of the private subnet the default VPC
resource "aws_subnet" "webservers_private" {
  count             = length(var.private_cidr)
  vpc_id            = aws_vpc.main_cidr.id
  cidr_block        = var.private_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
    }
  )
}

#  Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_cidr.id
  tags = merge(
    local.default_tags, {
      "Name" = "${local.name_prefix}-igw"
    }
  )

}

# NatGateway
resource "aws_eip" "main" {
  count  = var.create_nat_gateway ? 1 : 0

  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-natgw"
    }
  )
}

resource "aws_nat_gateway" "main" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.main[0].id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.igw]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-nat_gateway"
    }
  )
}





resource "aws_route_table" "public_routetable" {
  vpc_id = aws_vpc.main_cidr.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-public-route_table"
    }
  )
}

resource "aws_route_table" "webservers_private_routetable" {
  vpc_id = aws_vpc.main_cidr.id

  dynamic "route" {
    for_each = var.create_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-private-route_table"
    }
  )
}





resource "aws_route_table_association" "public__subnet_routetable_assoication" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_routetable.id
}

resource "aws_route_table_association" "webservers_subnet_routetable_assoication" {
  count          = length(aws_subnet.webservers_private)
  subnet_id      = aws_subnet.webservers_private[count.index].id
  route_table_id = aws_route_table.webservers_private_routetable.id
}