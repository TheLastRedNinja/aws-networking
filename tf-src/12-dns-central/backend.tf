terraform {
  backend "s3" {
    bucket         = "denis-murphy-terraform-state-store"
    dynamodb_table = "denis-murphy-terraform-state-lock-table"
    key            = "terraform/aws-deep-dive/12-dns-central"
    region         = "eu-west-1"
  }
}
