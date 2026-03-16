variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "lms-devops"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.29"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones_count" {
  description = "Number of AZs to use"
  type        = number
  default     = 2
}

variable "node_group_instance_types" {
  description = "EC2 instance types for EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}

variable "enable_cluster_autoscaler" {
  description = "Enable cluster autoscaler"
  type        = bool
  default     = false
}

variable "jenkins_worker_iam_role_arn" {
  description = "IAM role ARN for Jenkins workers (for IRSA or node role)"
  type        = string
  default     = ""
}

# Route53
variable "create_route53_zone" {
  description = "Create a new Route53 hosted zone"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for Route53 zone (e.g. app.example.com)"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "Existing Route53 hosted zone ID (if not creating one)"
  type        = string
  default     = ""
}

variable "route53_record_name" {
  description = "Record name (e.g. api or app) - subdomain or zone apex"
  type        = string
  default     = ""
}

variable "alb_dns_name" {
  description = "ALB DNS name (from Ingress after AWS LB Controller creates ALB)"
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "ALB hosted zone ID (from Ingress)"
  type        = string
  default     = ""
}
