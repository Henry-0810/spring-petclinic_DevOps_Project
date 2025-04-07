# resource "aws_security_group" "jenkins_sg" {
#   name        = "jenkins-sg"
#   description = "Allow Jenkins and SSH"
#
#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#
# resource "aws_instance" "jenkins" {
#   ami           = "ami-0c02fb55956c7d316"
#   instance_type = "t2.micro"
#   key_name      = var.key_name
#   security_groups = [aws_security_group.jenkins_sg.name]
#
#   user_data = <<-EOF
#               #!/bin/bash
#               yum update -y
#               amazon-linux-extras install docker -y
#               systemctl enable docker
#               service docker start
#               usermod -aG docker ec2-user
#
#               # Docker login
#               docker login -u ${var.dockerhub_user} -p ${var.dockerhub_token}
#
#               # Download backup file from public source
#               cd /home/ec2-user
#               curl -O ${var.jenkins_data}
#
#               # Restore Jenkins data to volume
#               docker volume create jenkins-data
#               docker run --rm -v jenkins-data:/restore -v /home/ec2-user:/backup alpine \
#                 tar -xzvf /backup/jenkins-home-backup.tar.gz -C /restore
#
#               # Start Jenkins with restored volume
#               docker run -d \
#                 --name jenkins-devops \
#                 -p 8080:8080 -p 50000:50000 \
#                 -v jenkins-data:/var/jenkins_home \
#                 henry0810/jenkins-server:lts
#               EOF
#
#   tags = {
#     Name = "JenkinsCI"
#   }
# }
#
# resource "aws_eip" "jenkins_eip" {
#   instance = aws_instance.jenkins.id
#   vpc      = true
# }
#
# output "jenkins_public_ip" {
#   description = "Elastic IP of Jenkins server"
#   value       = aws_eip.jenkins_eip.public_ip
# }
