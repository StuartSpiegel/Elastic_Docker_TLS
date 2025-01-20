provider "aws" {
  region = var.aws_region
}

# Networking Module
module "network" {
  source      = "./modules/network"
  cidr_block  = var.vpc_cidr_block
}

# Security Groups Module
module "security" {
  source  = "./modules/security"
  vpc_id  = module.network.vpc_id
}

# Elasticsearch Master Nodes
module "es_master" {
  source            = "./modules/compute"
  instance_count    = 3
  instance_type     = var.master_instance_type
  ami_id            = var.ami_id
  subnet_ids        = module.network.subnet_ids
  security_group_ids = [module.security.master_sg]
  user_data         = file("${path.module}/scripts/elasticsearch_master.sh")
}

# Elasticsearch Data Nodes
module "es_data" {
  source            = "./modules/compute"
  instance_count    = 3
  instance_type     = var.data_instance_type
  ami_id            = var.ami_id
  subnet_ids        = module.network.subnet_ids
  security_group_ids = [module.security.data_sg]
  user_data         = file("${path.module}/scripts/elasticsearch_data.sh")
}

# Kibana Nodes
module "kibana" {
  source            = "./modules/compute"
  instance_count    = 2
  instance_type     = var.kibana_instance_type
  ami_id            = var.ami_id
  subnet_ids        = module.network.subnet_ids
  security_group_ids = [module.security.kibana_sg]
  user_data         = file("${path.module}/scripts/kibana.sh")
}
