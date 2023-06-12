terraform {
  backend "s3" {
    encrypt 	   = true
    bucket 	   = "skabrits-bucket"
    dynamodb_table = "skabrits-tf-state-ldb"
    key            = "lock-file/terraform.tfstate"
    region         = "us-east-1"
  }
}
