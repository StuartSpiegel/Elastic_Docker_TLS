resource "aws_instance" "instance" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, count.index)

  # Use vpc_security_group_ids instead of security_group_ids
  vpc_security_group_ids = var.security_group_ids

  user_data = var.user_data

  tags = {
    Name = "Elasticsearch-${count.index}"
  }
}

output "instance_ips" {
  value = aws_instance.instance[*].private_ip
}
