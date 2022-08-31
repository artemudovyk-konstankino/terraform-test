terraform {
  backend "s3" {
    bucket = "test-terraform-au"
    key    = "terraform.tfstate"
    region = "us-east-1"
    profile = "personal"
  }
}