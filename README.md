# n8n Backoffice Infrastructure

This repository contains the **Terraform** code and **Docker Compose** files to deploy **n8n**, **PostgreSQL**, **Redis**, and **NGINX (HTTPS)** on **Google Cloud Compute Engine**.

## 🌐 Domain
`n8n-backoffice.startupcto.com.br`

## 🚀 Deployment Steps

### Prerequisites
- Google Cloud project with billing enabled
- Terraform installed (>= 1.0)
- Git installed
- Domain `n8n-backoffice.startupcto.com.br` pointing to GCP (DNS A Record)

### 1. Clone This Repository
```bash
git clone https://github.com/cassiopaixao/n8n-infra.git
cd n8n-infra/terraform
```

### 2. Initialize & Apply Terraform
```bash
terraform init
terraform apply -var="project_id=cptech-sandbox"
```
- This will create a VM and firewall rules.
- Outputs the **external IP address**.

### 3. Upload Your .env File to the VM
Use `gcloud scp` or `scp` to transfer your environment file (which is not in the repository) securely:

Using gcloud:
```bash
gcloud compute scp ./docker/.env n8n-backoffice:/opt/n8n/docker/.env --zone=us-central1-a
```

Or using scp:
```bash
scp ./docker/.env USER@VM_EXTERNAL_IP:/opt/n8n/docker/.env
```

### 4. SSH into the VM & Start Docker Compose
```bash
gcloud compute ssh n8n-backoffice --zone=us-central1-a
```
```bash
cd /opt/n8n/docker
sudo docker-compose --env-file .env up -d
```

### 5. Issue SSL Certificate (First Time Only)
```bash
sudo docker-compose run --rm certbot certonly --webroot --webroot-path=/var/www/certbot --email cassio.paixao@gmail.com --agree-tos --no-eff-email -d n8n-backoffice.startupcto.com.br
sudo docker-compose restart nginx
```

### 6. Automate SSL Renewal (Optional)
```bash
(crontab -l 2>/dev/null; echo "0 0,12 * * * cd /opt/n8n/docker && docker-compose --env-file .env run --rm certbot renew --webroot --webroot-path=/var/www/certbot && docker-compose exec nginx nginx -s reload") | crontab -
```

## ✅ Access n8n
https://n8n-backoffice.startupcto.com.br

---

## 📂 Folder Structure
```
terraform/       # Terraform files for provisioning
 ├── main.tf
 ├── outputs.tf
 ├── variables.tf
 └── versions.tf

docker/          # Docker Compose files and nginx config
 ├── docker-compose.yml
 ├── nginx.conf
 └── .env.example
```
