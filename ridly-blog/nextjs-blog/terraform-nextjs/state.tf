
terraform {
  backend "s3" {
    bucket = "ridly4-my-terraform-state" 
    key = "global/s3/terraform.tfstate"    
    region = "us-east-2"
    dynamodb_table = "terraformjs-lock-file"
    }
        
    
}