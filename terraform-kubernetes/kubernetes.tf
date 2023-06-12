provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    encrypt 	   = true
    bucket 	   = "skabrits-bucket"
    dynamodb_table = "skabrits-tf-state-ldb"
    key            = "lock-file/kube/terraform.tfstate"
    region         = "us-east-1"
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3" 

  config = {
    encrypt 	   = true
    bucket 	   = "skabrits-bucket"
    dynamodb_table = "skabrits-tf-state-ldb"
    key            = "lock-file/eks/terraform.tfstate"
    region         = "us-east-1"
  }
}

# Retrieve EKS cluster configuration
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "djn" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "rgi" {
  metadata {
    name = "regcred1"
    namespace = var.namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = var.registry_username
          "password" = var.registry_password
          "email"    = var.registry_email
          "auth"     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }

  depends_on = [
    kubernetes_namespace.djn
  ]
}

data "aws_caller_identity" "current" {}

resource "kubernetes_secret" "rgi_ecr" {
  metadata {
    name = "regcred2"
    namespace = var.namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.main_region}.amazonaws.com" = {
          "username" = "AWS"
          "password" = "${var.registry_password_ecr}"
          "auth"     = base64encode("AWS:${var.registry_password_ecr}")
        }
      }
    })
  }
  
  depends_on = [
    kubernetes_namespace.djn
  ]
}
