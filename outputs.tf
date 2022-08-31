output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance."
  value = aws_instance.my_vm.public_ip
}

output "vpc_id" {
  description = "ID of VPC."
  value = aws_vpc.main.id
}

output "ami_id" {
  description = "EC2 AMI."
  value = data.aws_ami.latest_amazon_linux2.id
}