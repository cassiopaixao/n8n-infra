output "n8n_vm_name" {
  description = "The name of the n8n Compute Engine instance"
  value       = google_compute_instance.n8n_vm.name
}

output "n8n_vm_zone" {
  description = "The zone where the n8n VM is deployed"
  value       = google_compute_instance.n8n_vm.zone
}

output "n8n_vm_external_ip" {
  description = "The external IP address of the n8n VM"
  value       = google_compute_instance.n8n_vm.network_interface[0].access_config[0].nat_ip
}
