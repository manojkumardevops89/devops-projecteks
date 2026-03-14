# Route53 - optional: create a new hosted zone or use existing zone ID
# Set create_route53_zone = true and domain_name to create a new zone.
# Set route53_zone_id to use an existing zone (e.g. from your registrar).

resource "aws_route53_zone" "main" {
  count = var.create_route53_zone ? 1 : 0

  name    = var.domain_name
  comment = "Managed by Terraform for ${var.project_name}"

  tags = {
    Name = "${var.project_name}-${var.environment}-zone"
  }
}

# ALB alias record - create after ALB exists (set alb_dns_name and alb_zone_id)
# Get ALB details: kubectl get ingress -n <namespace> then describe the ALB in AWS console
resource "aws_route53_record" "app" {
  count = (var.alb_dns_name != "" && var.alb_zone_id != "") && (var.create_route53_zone || var.route53_zone_id != "") ? 1 : 0

  zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : var.route53_zone_id
  name    = var.route53_record_name != "" ? var.route53_record_name : var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
