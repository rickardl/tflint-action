provider "aws" {
  version = ">= 2.48"
  region  = "us-east-1"
}

resource "null_resource" "echo" {

  provisioner "local-exec" {
    command = "echo Hello"
  }
}

resource "aws_instance" "foo" {
  ami           = "ami-0ff8a91507f77f867"
  instance_type = "t1.2xlarge" # invalid type!
}
