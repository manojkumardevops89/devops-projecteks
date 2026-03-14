# DevOps Project: Terraform, AWS EKS, Docker, Helm, Jenkins CI/CD

End-to-end DevOps setup with **Terraform** (VPC, EKS), **Docker**, **Kubernetes** manifests, **Helm** charts, **Jenkins** CI/CD, and **Route53** DNS.

---

## Architecture Overview

- **Terraform**: VPC (2 public + 2 private subnets), Internet Gateway, NAT Gateway, route tables, EKS cluster in private subnets, optional Route53.
- **EKS**: Kubernetes cluster; worker nodes in private subnets.
- **Microservices**: api-gateway, user-service, product-service (Python HTTP apps).
- **Ingress**: Kubernetes Ingress with AWS ALB (requires AWS Load Balancer Controller).
- **Helm**: One chart per microservice (Deployment, Service, ConfigMap, Secret).
- **Jenkins**: Checkout from GitHub → build Docker images → push to Docker Hub → deploy to EKS with Helm.
- **Route53**: Optional DNS record pointing your domain to the ALB.

---

## Repository Structure

```
devops-project/
├── terraform/                 # AWS infra + EKS + Route53
│   ├── providers.tf
│   ├── vpc.tf
│   ├── eks.tf
│   ├── route53.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── microservices/
│   ├── api-gateway/
│   │   ├── app.py
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── kubernetes/
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       ├── configmap.yaml
│   │       └── secret.yaml
│   ├── user-service/         # same structure
│   └── product-service/      # same structure
├── kubernetes/
│   ├── ingress.yaml         # ALB Ingress
│   └── README.md
├── helm/
│   ├── api-gateway/
│   ├── user-service/
│   └── product-service/
├── jenkins/
│   └── README.md
├── Jenkinsfile              # CI/CD pipeline
└── README.md                # this file
```

---

## 1. Terraform: AWS Infrastructure

### What it creates

- **VPC** with CIDR (default `10.0.0.0/16`)
- **2 public subnets**, **2 private subnets** (across 2 AZs)
- **Internet Gateway** and **NAT Gateway** (with route tables)
- **EKS cluster** and managed node group in **private subnets**
- **Route53** (optional): hosted zone and/or A record to ALB

### Prerequisites

- AWS CLI configured (or env vars)
- Terraform >= 1.0

### Commands

```bash
cd devops-project/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars (region, project name, etc.)
terraform init
terraform plan
terraform apply
```

### Configure kubectl

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
# Cluster name from: terraform output eks_cluster_name
```

### Route53 (optional)

- **New zone**: set `create_route53_zone = true` and `domain_name` in `terraform.tfvars`.
- **Existing zone**: set `route53_zone_id` to your hosted zone ID.
- **ALB record**: after the Ingress controller creates the ALB, set `alb_dns_name` and `alb_zone_id` (from ALB console or CLI), then `terraform apply` to create the A record.

---

## 2. AWS Load Balancer Controller (for Ingress ALB)

The Ingress in `kubernetes/ingress.yaml` provisions an **Application Load Balancer** only if the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/install/) is installed on the EKS cluster. Install it (e.g. via Helm or manifest) and configure IRSA using the EKS OIDC provider (Terraform output: `eks_oidc_provider_arn`).

---

## 3. Microservices (Docker + Kubernetes)

Each service has:

- **Dockerfile**: Python 3.11 slim image, exposes 8080.
- **Kubernetes**: `deployment.yaml`, `service.yaml`, `configmap.yaml`, `secret.yaml`.

### Build and run locally

```bash
cd devops-project/microservices/api-gateway
docker build -t api-gateway:latest .
docker run -p 8080:8080 api-gateway:latest
```

### Deploy with raw manifests

```bash
kubectl apply -f devops-project/microservices/api-gateway/kubernetes/
# Repeat for user-service and product-service
```

---

## 4. Kubernetes Ingress (ALB)

After the AWS LB Controller is running and services are deployed:

```bash
kubectl apply -f devops-project/kubernetes/ingress.yaml
kubectl get ingress
```

Use the Ingress ADDRESS (ALB hostname) to access:

- `/` and `/api` → api-gateway  
- `/users` → user-service  
- `/products` → product-service  

---

## 5. Helm Charts

Each microservice has a Helm chart under `helm/<service-name>/`.

### Install/upgrade

```bash
# From repo root
helm upgrade --install api-gateway devops-project/helm/api-gateway \
  --set image.repository=<your-registry>/api-gateway \
  --set image.tag=latest

helm upgrade --install user-service devops-project/helm/user-service \
  --set image.repository=<your-registry>/user-service \
  --set image.tag=latest

helm upgrade --install product-service devops-project/helm/product-service \
  --set image.repository=<your-registry>/product-service \
  --set image.tag=latest
```

Secrets and config can be overridden via `--set secret.*` and `--set config.*` or a custom `values.yaml`.

---

## 6. Jenkins CI/CD

The **Jenkinsfile**:

1. Checks out code from GitHub  
2. Builds Docker images for api-gateway, user-service, product-service  
3. Pushes images to Docker Hub (using credential ID `dockerhub-credentials`)  
4. Configures `kubectl` for EKS (using credential ID `aws-eks-credentials`)  
5. Deploys to EKS with Helm (`helm upgrade --install`) for each service  

Setup details (credentials, EKS cluster name, Docker Hub namespace) are in **jenkins/README.md**.

---

## 7. Route53 DNS

- Create a hosted zone in Terraform (`create_route53_zone = true`, `domain_name`) or use an existing one (`route53_zone_id`).
- After the ALB exists (from Ingress), set in `terraform.tfvars`:
  - `alb_dns_name` = ALB DNS name (e.g. `k8s-xxxxx.us-east-1.elb.amazonaws.com`)
  - `alb_zone_id` = ALB hosted zone ID
  - `route53_record_name` = subdomain or leave blank for zone apex
- Run `terraform apply` to create the A record (alias to the ALB).

Point your domain’s nameservers to the Route53 zone (if you created the zone in Terraform).

---

## Quick Start Summary

1. **Terraform**: `cd terraform && terraform init && terraform apply`  
2. **kubectl**: `aws eks update-kubeconfig --region <region> --name <cluster-name>`  
3. **AWS LB Controller**: Install on EKS (see link above)  
4. **Deploy apps**: Helm or `kubectl apply` for each microservice  
5. **Ingress**: `kubectl apply -f kubernetes/ingress.yaml`  
6. **Route53**: Set ALB vars and apply Terraform for DNS  
7. **Jenkins**: Add credentials and create Pipeline from `Jenkinsfile`  

---

## Security Notes

- Do not commit `terraform.tfvars` with secrets; use a secret manager or CI variables for sensitive values.
- Replace placeholder secrets in ConfigMaps/Secrets and in Helm `values.yaml` for production.
- Prefer IAM roles (e.g. IRSA) for Jenkins when running in AWS.
