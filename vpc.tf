# Create a VPC
resource "aws_vpc" "servers_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "servers-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.servers_vpc.id
  tags = {
    Name = "vpc_igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.servers_vpc.id
  cidr_block        = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "us-west-1b"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet_apache" {
  vpc_id            = aws_vpc.servers_vpc.id
  cidr_block        = var.private_subnet_apache_cidr
  availability_zone = "us-west-1b"

  tags = {
    Name = "private-subnet-apache"
  }
}

resource "aws_subnet" "private_subnet_nginx" {
  vpc_id            = aws_vpc.servers_vpc.id
  cidr_block        = var.private_subnet_nginx_cidr
  availability_zone = "us-west-1c"

  tags = {
    Name = "private-subnet-nginx"
  }
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.public_subnet.id
  tags = {
    "Name" = "nat_gateway"
  }
}

output "nat_gateway_ip" {
  value = aws_eip.eip.public_ip
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.servers_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "private_rt"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.servers_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_asso" {
  subnet_id = aws_subnet.private_subnet_apache.id
  route_table_id = aws_route_table.private_rt.id
}