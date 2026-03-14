output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "Private subnet IDs (EKS nodes)"
  value       = module.vpc.private_subnets
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "eks_cluster_certificate_authority_data" {
  description = "EKS cluster CA certificate"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN (for ALB Ingress Controller IRSA)"
  value       = module.eks.oidc_provider_arn
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID (if created)"
  value       = try(aws_route53_zone.main[0].zone_id, var.route53_zone_id)
}

output "route53_zone_name_servers" {
  description = "Route53 name servers for the zone"
  value       = try(aws_route53_zone.main[0].name_servers, [])
}

output "alb_dns_name" {
  description = "ALB DNS name (set after Ingress is created in cluster)"
  value       = "Set via Kubernetes Ingress status after AWS LB Controller provisions ALB"
}
