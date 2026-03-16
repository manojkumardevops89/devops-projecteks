resource "aws_iam_role_policy_attachment" "alb_controller_policy" {

  role       = module.eks.eks_managed_node_groups["main"].iam_role_name

  policy_arn = "arn:aws:iam::400516512948:policy/AWSLoadBalancerControllerIAMPolicy"
}
