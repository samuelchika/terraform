provider "aws" {
  region = "eu-west-1"
  access_key = "ur access key"
  secret_key = "your secret key"
}

##automate the creating of keypair

#output
output "server_id" {
  description = "Our webserver id"
  value = aws_instance.web_server.id
}
output "server_public_ip" {
    description = "Globa IP address"
    value = aws_instance.web_server.public_ip
}
output "server_public_dns" {
    description = "Globa IP address"
    value = aws_instance.web_server.public_dns
}

resource "aws_security_group" "web_server_sg" {
    vpc_id = "default vpc"
    ingress  {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["ur ip address"]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
      Name = "test-sg"
    }
}

#create ec2 instance
# GET THE DEFAULT INSTANCE.
data "aws_ami" "amazon_linux_image" {
  most_recent = true
  owners = ["amazon"]
  # this filters the images/ami and look for the one with the name starting with amxn2-ami-hvm- and has anything inbetween and ends with x86_64-gp2
  filter {
      name = "name"
      values = [ "amzn2-ami-hvm-*-x86_64-gp2" ]
  }
  # we can filter with the virtualization-type
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "web_server" {
  ami = data.aws_ami.amazon_linux_image.id
  instance_type = "t2.micro"
  availability_zone = "eu-west-1a"
  associate_public_ip_address = true
  key_name = "test"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  user_data = <<EOF
                #!/bin/bash
                sudo yum update -y && sudo yum install -y docker
                sudo systemctl start docker
                sudo usermod -aG docker ec2-user
                docker run -p 8080:80 nginx
                EOF


  tags = {
      Name = "terrform-server"
  }
}