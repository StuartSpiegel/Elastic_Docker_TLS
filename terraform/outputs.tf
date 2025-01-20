output "master_ips" {
  value = module.es_master.instance_ips
}

output "data_ips" {
  value = module.es_data.instance_ips
}

output "kibana_ips" {
  value = module.kibana.instance_ips
}
