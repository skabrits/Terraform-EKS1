provider "aws" {
  region = var.main_region
}

terraform {
  backend "s3" {
    encrypt 	   = true
    bucket 	   = "skabrits-bucket"
    dynamodb_table = "skabrits-tf-state-ldb"
    key            = "lock-file/helm/terraform.tfstate"
    region         = "us-east-1"
  }
}

resource "aws_s3_bucket_object" "object" {
   bucket = "skabrits-bucket"
   key    = "helm/charts/index.yaml"
   source = "./index.yaml"
}