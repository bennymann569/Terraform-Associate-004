data "aws_ssm_parameter" "amzn2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "tfe_outputs" "networking" {
  organization = "ned-0527-org"
  workspace    = "taco-wagon-networking"
}

data "aws_subnet" "selected" {
  id = data.tfe_outputs.networking.nonsensitive_values.public_subnet_id
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.aws_subnet.selected.vpc_id

  ingress {
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

  tags = var.common_tags
}

resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.amzn2_ami.value
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to the Taco Wagon App</h1>" > /var/www/html/index.html
              EOF

  user_data_replace_on_change = true

  tags = var.common_tags
}
