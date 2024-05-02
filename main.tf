provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  
  
  tags = { Name = "Project VPC"
    }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true


  tags = {
    Name = "Main Subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet.id
}

resource "aws_network_interface" "multi" {
    subnet_id = aws_subnet.public_subnet.id
    private_ips = ["10.0.1.5", "10.0.1.6"]
}

resource "aws_eip" "eip-one" {
  domain = "vpc"
  network_interface = aws_network_interface.multi.id
  instance = aws_instance.project_server[0].id
}

resource "aws_eip" "eip-two" {
  domain = "vpc"
  network_interface = aws_network_interface.multi.id
  instance = aws_instance.project_server[1].id
}

resource "aws_instance" "project_server" {
  ami = "ami-008ea0202116dbc56"
  instance_type = var.instance_type
  count = var.ec2_instance_count

 /* security_groups = [
    "${aws_security_group.security.id}",
  ] */

  tags = {
    Name = "Project Server"
  }

    user_data = <<-EOF
             #!/bin/bash
             sudo apt-get update
             sudo apt-get install -y nginx
             sudo systemctl start nginx
             sudo systemctl enable nginx
             echo '<!doctype html>
             <html lang="en"><h1>Home page!</h1></br>
             <h3>(Instance A)</h3>
             </html>' | sudo tee /var/www/html/index.html
             EOF

}

resource "aws_s3_bucket" "project_bucket" {
  bucket = "tf-project-bucket-garproj"

  tags = {
    Name = "Project Bucket"
    Environment = "Dev"
  }
}

//Security Groups
resource "aws_security_group" "allow_tls" {
    name = "allow_tls"
    description = "Allow TLS inbound traffic and all outbound traffic"
    vpc_id = aws_vpc.main.id

    tags = {
      Name = "allow_tls"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
    security_group_id = aws_security_group.allow_tls.id
    cidr_ipv4 = aws_vpc.main.cidr_block
    from_port = 443
    
    ip_protocol = "tcp"
    to_port = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

/* resource "aws_security_group" "security" {
  name = "allow-all"

  vpc_id = aws_vpc.main.id

  ingress {
    cidr_blocks = [
        "0.0.0.0/0"
    ]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks  = ["0.0.0.0/10"]
  }
} */

/*Load Balancers
resource "aws_lb_target_group" "lb_tg_a" {
    name = "target-group-a"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
}

resource "aws_lb_target_group" "lb_tg_b" {
    name = "target-group-b"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "tg_attachment_a" {
  target_group_arn = aws_lb_target_group.lb_tg_a.arn
  target_id = aws_instance.project_server[0].id
  port = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment_b" {
  target_group_arn = aws_lb_target_group.lb_tg_b.arn
  target_id = aws_instance.project_server[1].id
  port = 80
}

resource "aws_lb" "project_lb" {
  name = "project-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = aws_instance.project_server
  subnets = public_subnet
} */

data "aws_region" "current" { }