terraform{
    required providers{
        aws = {
            source = "hashicorp/aws"
            version = "4.67.0"
        }
    }
}

region = var.region