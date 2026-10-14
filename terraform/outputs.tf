output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.gift_vpc.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = aws_subnet.gift_subnet.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.gift_igw.id
}

output "route_table_id" {
  description = "Route Table ID"
  value       = aws_route_table.gift_route_table.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.gift_sg.id
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.gift_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.gift_server.public_ip
}

