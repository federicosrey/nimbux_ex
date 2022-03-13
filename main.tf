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
/*resource "aws_instance" "nginx-server" {
  ami                    = "ami-0a8a24772b8f01294"
  instance_type          = var.instance_type
  key_name               = var.instance_key
  subnet_id              = aws_subnet.private_subnet_nginx.id
  vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id]
  //associate_public_ip_address = "true"
  
  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y nginx
                systemctl start nginx
                systemctl enable nginx
                touch /home/ec2-user/edgardito
                EOF

  tags = {
    Name = "nginx-server"
  }
}*/

resource "aws_instance" "apache-server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.instance_key
  subnet_id              = aws_subnet.private_subnet_apache.id
  vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id]
    
  user_data = <<-EOF
                #!/bin/bash
                apt update -y
                apt install -y apache2
                service apache2 start
                EOF

  tags = {
    Name = "apache-server"
  }
}

# ----------------------------------------------
# Define la segunda instancia EC2 con AMI Ubuntu
# ----------------------------------------------
resource "aws_instance" "nginx-server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.instance_key
  subnet_id              = aws_subnet.private_subnet_nginx.id
  vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id]
  
  user_data = <<EOF
                #!/bin/bash -xe
                apt-get update
                apt-get install -y nginx
                systemctl start nginx.service
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

  subnets = [aws_subnet.public_subnet_az1.id,aws_subnet.public_subnet_az2.id]
}

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
