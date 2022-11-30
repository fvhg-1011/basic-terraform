#initiate server AMI
data "aws_ami" "server_instance" {
  most_recent = true
  owners      = ["099720109477"]

  # choosing specific instace ami server which is ubuntu 18.04 bases on value from AMI name
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}
