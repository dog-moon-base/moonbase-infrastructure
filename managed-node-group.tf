resource "aws_eks_node_group" "production" {
  cluster_name    = local.cluster_name
  node_group_name = "production"
  subnet_ids      = module.vpc.private_subnets
  node_role_arn   = aws_iam_role.production.arn

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.production-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.production-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.production-AmazonEC2ContainerRegistryReadOnly,
  ]

}

resource "aws_iam_role" "production" {
  name = "eks-node-group-production"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "production-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.production.name
}

resource "aws_iam_role_policy_attachment" "production-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.production.name
}

resource "aws_iam_role_policy_attachment" "production-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.production.name
}
