resource "aws_iam_role" "eks_cluster" {
  name = "eks_cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}


#=========================

######## BUILDING EKS CLUSTER############

#==========================
# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks_cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "eks" {
  name     = "eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.18"
  vpc_config {
    subnet_ids              = [aws_subnet.public_1.id, aws_subnet.public_2.id, aws_subnet.private_1.id, aws_subnet.private_2.id]
    endpoint_private_access = false
    endpoint_public_access  = true

  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_cluster-AmazonEKSVPCResourceController
  ]
}

output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

