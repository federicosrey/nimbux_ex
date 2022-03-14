# ------------------------------------------------------
# Define un grupo de seguridad con acceso al puerto 8080
# ------------------------------------------------------

resource "aws_security_group" "servers-sg" {
  name = "servers-sg"
  vpc_id = aws_vpc.servers_vpc.id

  ingress {
    security_groups = [aws_security_group.alb.id]
    description     = "Acceso al puerto 80 desde el exterior"
    from_port       = 80
    to_port         = 80
    protocol        = "TCP"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  } 
}

# ------------------------------------
# Security group para el Load Balancer
# ------------------------------------

resource "aws_security_group" "alb" {
  name = "alb-sg"
  vpc_id = aws_vpc.servers_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 80 desde el exterior"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
   
  }
}   