resource "google_compute_instance" "n8n_vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2404-lts-amd64"
      size  = var.disk_size_gb
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io docker-compose
    mkdir -p /opt/n8n
    cd /opt/n8n
    git clone https://github.com/cassiopaixao/n8n-infra.git .
    cd docker
    docker-compose --env-file .env up -d
  EOT

  tags = ["n8n-backoffice"]

  lifecycle {
    ignore_changes = [
      metadata_startup_script
    ]
  }
}

resource "google_compute_firewall" "n8n_firewall" {
  name    = "n8n-allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["n8n-backoffice"]
}