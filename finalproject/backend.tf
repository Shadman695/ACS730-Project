terraform {
  backend "s3" {
    bucket = "finalprojectssk"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}