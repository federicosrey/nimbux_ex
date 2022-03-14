# -------------------------
# Define el provider de AWS
# -------------------------
provider "aws" {
  region = var.region
  profile = "default"
}

# -----------------------------
# Define el algoritmo de la key
# -----------------------------
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# -----------------------------
# Define el keypair
# -----------------------------

resource "aws_key_pair" "ssh" {
  key_name = var.key_name
  public_key = tls_private_key.ssh.public_key_openssh
}


# --------------------------------------------------
# Define una instancia EC2 con AMI Ubuntu con Apache
# --------------------------------------------------

resource "aws_instance" "apache-server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh.key_name
  subnet_id              = aws_subnet.private_subnet_apache.id
  vpc_security_group_ids = [aws_security_group.servers-sg.id]
    
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

# --------------------------------------------------------
# Define la segunda instancia EC2 con AMI Ubuntu con Nginx
# --------------------------------------------------------
resource "aws_instance" "nginx-server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh.key_name
  subnet_id              = aws_subnet.private_subnet_apache.id
  vpc_security_group_ids = [aws_security_group.servers-sg.id]
  
  user_data = <<-EOF
                #!/bin/bash
                apt-get update
                apt-get -y install nginx
                EOF
  
  tags = {
    Name = "nginx-server"
  }
}

# ----------------------------------------
# Load Balancer público con dos instancias
# ----------------------------------------
resource "aws_lb" "alb" {
  load_balancer_type = var.load_balancer_type
  name               = var.load_balancer_name
  security_groups    = [aws_security_group.alb.id]

  subnets = [aws_subnet.public_subnet_az1.id,aws_subnet.public_subnet_az2.id]
}

# ----------------------------------
# Target Group para el Load Balancer
# ----------------------------------
resource "aws_lb_target_group" "this" {
  name     = var.tg_name
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
# ----------------------------------
# Attachment para el servidor apache
# ----------------------------------
resource "aws_lb_target_group_attachment" "apache-server-att" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.apache-server.id
  port             = 80
}

# ---------------------------------
# Attachment para el servidor nginx
# ---------------------------------
resource "aws_lb_target_group_attachment" "nginx-server-att" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.nginx-server.id
  port             = 80
}

# --------------------
# Listener para el ALB
# --------------------
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}
