# n8n Backoffice Infrastructure

This repository contains the **Terraform** code and **Docker Compose** files to deploy **n8n**, **PostgreSQL**, **Redis**, and **NGINX (HTTPS)** on **Google Cloud Compute Engine**.

## 🌐 Domain
`n8n.example.com`

Note: You should update it in your .env

## 🚀 Deployment Steps

### Prerequisites
- Google Cloud project with billing enabled
- Terraform installed (>= 1.0)
- Git installed
- A domain pointing to your VM external IP

### 1. Clone This Repository
```bash
git clone https://github.com/cassiopaixao/n8n-infra.git
cd n8n-infra/terraform
```

### 2. Initialize & Apply Terraform
```bash
terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID"
```
- This will create a VM and firewall rules.
- Outputs the **external IP address**. You should create an **A** DNS record pointing to this IP address.

### 3. Upload Your .env File to the VM
Use `gcloud scp` or `scp` to transfer your environment file (see `./docker/.env.example`) securely:

```bash
gcloud compute scp ./docker/.env n8n-backoffice:~/.env --zone=us-central1-a
# or
scp ./docker/.env USER@VM_EXTERNAL_IP:~/.env
```

### 4. SSH into the VM and move the .env file
```bash
gcloud compute ssh n8n-backoffice --zone=us-central1-a
sudo mv ~/.env /opt/n8n/docker/.env
cd /opt/n8n/docker
```

### 5. Generate nginx.conf from template
```bash
export $(grep -v '^#' .env | xargs)
envsubst '${DOMAIN}' < ./nginx/nginx.conf.template | sudo tee ./nginx/nginx.conf > /dev/null
envsubst '${DOMAIN}' < ./nginx/nginx.bootstrap.conf.template | sudo tee ./nginx/nginx.bootstrap.conf > /dev/null
```

### 6. Bootstrap NGINX without SSL (first time only)
```bash
export $(grep -v '^#' .env | xargs)
sudo docker run -d \
  --name nginx-bootstrap \
  -p 80:80 \
  -v $(pwd)/nginx/nginx.bootstrap.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/data/certbot/www:/var/www/certbot \
  nginx:alpine
```

### 7. Issue the SSL Certificate
```bash
export $(grep -v '^#' .env | xargs)
sudo docker-compose run --rm certbot certonly \
  --webroot --webroot-path=/var/www/certbot \
  --email ${CERTIFICATE_EMAIL} --agree-tos --no-eff-email \
  -d ${DOMAIN}
```

### 8. Stop the temporary NGINX and start full stack
```bash
sudo docker rm -f nginx-bootstrap
sudo docker-compose --env-file .env up -d
```

### 9. Automate SSL Renewal (Optional)
```bash
(crontab -l 2>/dev/null; echo "0 0,12 * * * cd /opt/n8n/docker && docker-compose --env-file .env run --rm certbot renew --webroot --webroot-path=/var/www/certbot && docker-compose exec nginx nginx -s reload") | crontab -
```

## ✅ Access n8n
https://n8n.example.com (or the domain you set up in your `.env`)
