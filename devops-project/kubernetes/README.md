# Kubernetes Manifests and Ingress

## Prerequisites

1. **AWS Load Balancer Controller** must be installed on the EKS cluster for Ingress to create an ALB:
   - [Installation guide](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/install/)
   - Uses IAM Roles for Service Accounts (IRSA); ensure OIDC is enabled on the cluster (Terraform EKS module enables it).

2. Deploy microservices (via Helm or raw manifests) before applying the Ingress.

## Apply Ingress

```bash
kubectl apply -f ingress.yaml
kubectl get ingress  # ALB address appears in ADDRESS once provisioned
```

## Route53

After the ALB is created, get its DNS name and hosted zone ID from AWS Console or:

```bash
kubectl get ingress -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
```

Then set `alb_dns_name` and `alb_zone_id` in Terraform and apply to create the Route53 alias record.
