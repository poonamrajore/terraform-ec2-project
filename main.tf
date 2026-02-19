provider "aws" {
	region = var.region 
}

# security group 

resource "aws_security_group" "web_sg" {
    name = "web-sg"
    description = "Allow SSH and HTTP"
 
  ingress { 
     description = "SSH"
     from_port = 22
      to_port = 22
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}

ingress {
   description = "HTTP"
    from_port = 80
     to_port =  80
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port = 0
     to_port = 0
     protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }
provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }

  provisioner "file" {
    source      = "website/index.html"
    destination = "/home/ubuntu/index.html"
  }
provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /var/www/html/*",
      "sudo cp /home/ubuntu/index.html /var/www/html/",
      "sudo chown www-data:www-data /var/www/html/index.html",
      "sudo chmod 644 /var/www/html/index.html",
      "sudo systemctl restart nginx"
    ]
  }

  tags = {
    Name = "VPC-Website"
  }
}
output "public_ip" {
  value = aws_instance.web.public_ip
}
