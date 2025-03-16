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
    apt-get install -y docker.io docker-compose git

    mkdir -p /opt/n8n
    cd /opt/n8n

    # Wait for network to be ready
    sleep 10

    echo "Cloning repository..." >> /var/log/startup-script.log 2>&1
    git clone https://github.com/cassiopaixao/n8n-infra.git /opt/n8n >> /var/log/startup-script.log 2>&1

    cd /opt/n8n/docker

    echo "Waiting for .env file upload before starting docker-compose..." >> /var/log/startup-script.log 2>&1

    # Wait until the .env file is uploaded (timeout 5 minutes)
    TIMEOUT=300
    WAIT=0
    while [ ! -f /opt/n8n/docker/.env ] && [ $WAIT -lt $TIMEOUT ]; do
      sleep 5
      WAIT=$((WAIT + 5))
    done

    if [ -f /opt/n8n/docker/.env ]; then
      echo ".env file found. Starting docker-compose..." >> /var/log/startup-script.log 2>&1
      docker-compose --env-file .env up -d
    else
      echo "Timeout waiting for .env file. Docker-compose was not started." >> /var/log/startup-script.log 2>&1
    fi
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