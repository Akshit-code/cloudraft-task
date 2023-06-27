# Define the provider
provider "aws" {
  region = "us-east-1"
}
provider "kubernetes" {
  config_path = "/home/akshit/.kube/config"  
}

# Create a new VPC
resource "aws_vpc" "task_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway
resource "aws_internet_gateway" "task_igw" {
  vpc_id = aws_vpc.task_vpc.id
}

# Create a default route table
resource "aws_route_table" "task_route_table" {
  vpc_id = aws_vpc.task_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task_igw.id
  }
}

# Associate the route table with the default subnet
resource "aws_route_table_association" "task_subnet1_association" {
  subnet_id      = aws_subnet.task_subnet.id
  route_table_id = aws_route_table.task_route_table.id
}

resource "aws_route_table_association" "task_subnet2_association" {
  subnet_id      = aws_subnet.task_subnet2.id
  route_table_id = aws_route_table.task_route_table.id
}


# Create a security group for the EKS cluster
resource "aws_security_group" "task_eks_sg" {
  name        = "task-eks-security-group"
  description = "Security group for the EKS cluster"
  vpc_id      = aws_vpc.task_vpc.id
}

# Allow inbound traffic on port 22 (SSH) and 6443 (EKS API server)
resource "aws_security_group_rule" "ssh_rule" {
  security_group_id = aws_security_group.task_eks_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "api_server_rule" {
  security_group_id = aws_security_group.task_eks_sg.id
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Create a subnet within the VPC
resource "aws_subnet" "task_subnet" {
  vpc_id                  = aws_vpc.task_vpc.id
  cidr_block              = "10.0.1.0/24"  # Replace with your desired subnet CIDR block
  availability_zone       = "us-east-1a"  # Replace with your desired availability zone
  map_public_ip_on_launch = true
}

resource "aws_subnet" "task_subnet2" {
  vpc_id                  = aws_vpc.task_vpc.id
  cidr_block              = "10.0.2.0/24"  # Replace with your desired subnet CIDR block for the second subnet
  availability_zone       = "us-east-1b"  # Replace with your desired availability zone for the second subnet
  map_public_ip_on_launch = true
}

# Create the EKS cluster
resource "aws_eks_cluster" "task_cluster" {
  name     = "task-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.task_subnet.id, aws_subnet.task_subnet2.id]
    security_group_ids = [aws_security_group.task_eks_sg.id]
    endpoint_private_access = true
    endpoint_public_access = true
  }
}

# Define the IAM role for the EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "task-eks-cluster-role"

  assume_role_policy = <<EOF
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
EOF
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "task-eks-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach the required policies to the IAM role
resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "task_node_group_policies" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "task_node_group_ecr_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create the EKS node group
resource "aws_eks_node_group" "task_node_group" {
  cluster_name    = aws_eks_cluster.task_cluster.name
  node_group_name = "task-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = [aws_subnet.task_subnet.id, aws_subnet.task_subnet2.id]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 3
  }

  remote_access {
    ec2_ssh_key     = "cloudraft_task_keypair"  # Specify the name of your SSH key pair
    source_security_group_ids = [aws_security_group.task_eks_sg.id]
  }
}

# Deploy your application to the EKS cluster
resource "kubernetes_namespace" "task_namespace" {
  metadata {
    name = "task-namespace"
  }
}

resource "kubernetes_deployment" "task_deployment" {
  metadata {
    name      = "key-value-store-api"
    namespace = kubernetes_namespace.task_namespace.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "key-value-store-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "key-value-store-api"
        }
      }

      spec {
        container {
          name  = "key-value-store-api"
          image = "public.ecr.aws/r4o7l7m3/cloudraft_task_repo:latest"
          image_pull_policy = "Always"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "task_service" {
  metadata {
    name      = "key-value-store-service"
    namespace = kubernetes_namespace.task_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "key-value-store-api"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}
# Output the cluster name and endpoint
output "cluster_name" {
  value = aws_eks_cluster.task_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.task_cluster.endpoint
}
