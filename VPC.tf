# create vpc
resource "aws_vpc" "cobain" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "Name" = "cobain-vpc"
  }
}

#create subnet
resource "aws_subnet" "cobain_public_subnet" {
  vpc_id                  = aws_vpc.cobain.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-3a"

  tags = {
    "Name" = "cobain-public-subnet"
  }

}

#create internet gateway
resource "aws_internet_gateway" "cobain_igw" {
  vpc_id = aws_vpc.cobain.id
  tags = {
    "Name" = "cobain-igw"
  }
}

#create route table
resource "aws_route_table" "cobain_public_route_table" {
  vpc_id = aws_vpc.cobain.id
  tags = {
    "Name" = "cobain-public-route-table"
  }
}

#routing for connecting to internet
resource "aws_route" "cobain_public_route" {
  route_table_id         = aws_route_table.cobain_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cobain_igw.id

}

#routing for subnet to internet gateway
resource "aws_route_table_association" "cobain_route_table_assoc" {
  subnet_id      = aws_subnet.cobain_public_subnet.id
  route_table_id = aws_route_table.cobain_public_route_table.id
}

#==========================create secuirty group==========================
resource "aws_security_group" "cobain_sg" {
  name        = "cobain_sg"
  description = "security group that created from terraform"
  vpc_id      = aws_vpc.cobain.id
  #allow the traffic to come 
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                 # allow all protocol
    cidr_blocks = ["180.241.18.11/32"] # set to 0.0.0.0 if want to allow everything or your own ip inside the square bracket
  }
  #allow the traffic to out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #allow all protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "cobain_sg"
  }
}


