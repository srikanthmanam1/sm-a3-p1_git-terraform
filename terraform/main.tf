#------------------------------------------------------------
# main.tf
#------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  no_av_zn = length(data.aws_availability_zones.available.names)
}

# VPC
resource "aws_vpc" "sm-std-vpc1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "sm_std_vpc1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "sm-std-igw1" {
  vpc_id = aws_vpc.sm-std-vpc1.id

  tags = {
    Name = "sm_std_igw1"
  }
}

# Public Subnets (3 AZs)
resource "aws_subnet" "sm-std-pub-sn1" {
#  count                   = 3
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.sm-std-vpc1.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "sm_std_pub_sn-${count.index + 1}"
  }
}

# Private Subnets (3 AZs)
resource "aws_subnet" "sm-std-pvt-sn1" {
#  count             = 3
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.sm-std-vpc1.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 4, count.index + local.no_av_zn)
#  cidr_block        = cidrsubnet("10.0.0.0/16", 4, count.index + 3)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "sm_std_pvt_sn-${count.index + 1}"
  }
}

# Public Route Table
resource "aws_route_table" "sm-std-pub-rt1" {
  vpc_id = aws_vpc.sm-std-vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sm-std-igw1.id
  }

  tags = {
    Name = "sm_std_pub_rt1"
  }
}

# Private Route Table
resource "aws_route_table" "sm-std-pvt-rt1" {
  vpc_id = aws_vpc.sm-std-vpc1.id

  tags = {
    Name = "sm_std_pvt_rt1"
  }
}

# Associate Public Subnets
resource "aws_route_table_association" "sm-std-pub-rta1" {
#  count          = 3
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.sm-std-pub-sn1[count.index].id
  route_table_id = aws_route_table.sm-std-pub-rt1.id
}

# Associate Private Subnets
resource "aws_route_table_association" "sm-std-pvt-rta1" {
#  count          = 3
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.sm-std-pvt-sn1[count.index].id
  route_table_id = aws_route_table.sm-std-pvt-rt1.id
}

# Security Group
resource "aws_security_group" "sm-std-sg1" {
  name        = "sm_std_sg1"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.sm-std-vpc1.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sm_std_tag_sg1"
  }
}
