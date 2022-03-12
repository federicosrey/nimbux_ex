# -------------------------
# Define el provider de AWS
# -------------------------
provider "aws" {
  region = var.region
  //shared_credentials_file = var.creds
  profile = "default"
}

# ---------------------------------------
# Define una instancia EC2 con AMI Ubuntu
# ---------------------------------------
resource "aws_instance" "apache-server" {
  ami                    = "ami-01f87c43e618bf8f0"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_apache.id
  vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id]
  associate_public_ip_address = "true"
  
  user_data = <<-EOF
                #!/bin/bash
                echo "*** Installing apache2"
                sudo apt update -y
                sudo apt install apache2 -y
                echo "*** Completed Installing apache2"
                sudo service apache2 start
                EOF

  tags = {
    Name = "apache-server"
  }
}

# ----------------------------------------------
# Define la segunda instancia EC2 con AMI Ubuntu
# ----------------------------------------------
resource "aws_instance" "nginx-server" {
  ami                    = "ami-01f87c43e618bf8f0"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_nginx.id
  vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id]
  associate_public_ip_address = "true"

  user_data = <<-EOF
                #!/bin/bash
                echo "*** Installing nginx"
                sudo apt update -y
                sudo apt install nginx -y
                echo "*** Completed Installing nginx"
                sudo service nginx start
                EOF
  tags = {
    Name = "nginx-server"
  }
}

# ----------------------------------------
# Load Balancer público con dos instancias
# ----------------------------------------
resource "aws_lb" "alb" {
  load_balancer_type = "application"
  name               = "terraformers-alb"
  security_groups    = [aws_security_group.alb.id]

  subnets = [aws_subnet.private_subnet_apache.id,aws_subnet.private_subnet_nginx.id]
}

# ----------------------------------------------------
# Data Source para obtener el ID de la VPC por defecto
# ----------------------------------------------------
/*data "aws_vpc" "default" {
  default = true
}*/

# ----------------------------------
# Target Group para el Load Balancer
# ----------------------------------
resource "aws_lb_target_group" "this" {
  name     = "terraformers-alb-target-group"
  port     = 80
  vpc_id   = aws_vpc.servers_vpc.id
  protocol = "HTTP"

  health_check {
    enabled  = true
    matcher  = "200"
    path     = "/"
    port     = "80"
    protocol = "HTTP"
  }
}

# -----------------------------
# Attachment para el servidor 1
# -----------------------------
resource "aws_lb_target_group_attachment" "servidor_1" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.apache-server.id
  port             = 80
}

# -----------------------------
# Attachment para el servidor 2
# -----------------------------
resource "aws_lb_target_group_attachment" "servidor_2" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.nginx-server.id
  port             = 80
}

# ------------------------
# Listener para nuestro LB
# ------------------------
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}
