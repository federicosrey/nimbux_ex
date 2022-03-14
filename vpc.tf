# --------------
# Define una VPC
# --------------

resource "aws_vpc" "servers_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# --------------------------
# Define un internet gateway
# --------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.servers_vpc.id
  tags = {
    Name = var.ig_name
  }
}

# -----------------------------------
# Define una subnet publica en el az1
# -----------------------------------

resource "aws_subnet" "public_subnet_az1" {
  vpc_id            = aws_vpc.servers_vpc.id
  cidr_block        = var.public_subnet_az1_cidr
  map_public_ip_on_launch = true
  availability_zone = "us-west-1b"

  tags = {
    Name = "public-subnet_az1"
  }
}

# -----------------------------------
# Define una subnet publica en el az2
# -----------------------------------

resource "aws_subnet" "public_subnet_az2" {
  vpc_id            = aws_vpc.servers_vpc.id
  cidr_block        = var.public_subnet_az2_cidr
  map_public_ip_on_launch = true
  availability_zone = "us-west-1c"

  tags = {
    Name = "public-subnet_az2"
  }
}

# ---------------------------------------------
# Define una subnet privada para los web server
# ---------------------------------------------

resource "aws_subnet" "private_subnet_apache" {
  vpc_id            = aws_vpc.servers_vpc.id
  cidr_block        = var.private_subnet_apache_cidr
  availability_zone = "us-west-1b"

  tags = {
    Name = "private-subnet-apache"
  }
}

# -----------------------------------------
# Define una elastic ip para el nat gateway
# -----------------------------------------

resource "aws_eip" "eip" {
  vpc = true
}

# -----------------------------------------
# Define un nat gateway para los servidores
# -----------------------------------------

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.public_subnet_az1.id
  tags = {
    "Name" = "nat_gateway"
  }
}

# --------------------------------------------
# Define un route table para la subnet privada
# --------------------------------------------

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

# --------------------------------------------
# Define un route table para la subnet publica
# --------------------------------------------

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

# ---------------------------------------------------------
# Define la asociacion de subnets publicas a la route table
# ---------------------------------------------------------

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_rt.id
}

# ---------------------------------------------------------
# Define la asociacion de subnets privadas a la route table
# ---------------------------------------------------------

resource "aws_route_table_association" "private_rt_asso" {
  subnet_id = aws_subnet.private_subnet_apache.id
  route_table_id = aws_route_table.private_rt.id
}
