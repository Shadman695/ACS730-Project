terraform{
    backend "s3"
    bucket = "finalprojectssk"
    key = "main/terraform.tfstate"
    region = "us-east-1"
    
}