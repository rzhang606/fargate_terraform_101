
#specify provider, access details

provider "aws" {
    shared_credentials_file = "C:/Users/Admin/.aws/credentials"
    profile = "default"
    region = "${var.aws_region}"
}