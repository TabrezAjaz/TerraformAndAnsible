output "web_public_ip" {
  description = "Public IPv4 address of the TravelMemory web server."
  value       = aws_instance.web.public_ip
}

output "application_url" {
  description = "URL of the deployed TravelMemory application after Ansible completes."
  value       = "http://${aws_instance.web.public_ip}"
}

output "web_private_ip" {
  description = "Private IPv4 address of the web server."
  value       = aws_instance.web.private_ip
}

output "database_private_ip" {
  description = "Private IPv4 address of the MongoDB server."
  value       = aws_instance.database.private_ip
}

output "ansible_inventory" {
  description = "Generated Ansible inventory path."
  value       = local_sensitive_file.ansible_inventory.filename
}
