variable "conta" {
    default = 1
  }
variable "region" {
  description = "AWS region for hosting our your network"
  default = "us-east-2"
}
variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default = "/home/ruben/Descargas/mykeypair.pem"
  
}
variable "key_name" {
  description = "Key name for SSHing into EC2"
  default = "mykeypair"
}
variable "amis" {
  description = "Base AMI to launch the instances"
  default = {
  us-east-2 = "ami-0dd9f0e7df0f0a138"
  }
}