resource "aws_security_group" "master" {
  name_prefix = "es-master"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "data" {
  name_prefix = "es-data"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kibana" {
  name_prefix = "kibana"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "master_sg" {
  value = aws_security_group.master.id
}

output "data_sg" {
  value = aws_security_group.data.id
}

output "kibana_sg" {
  value = aws_security_group.kibana.id
}
