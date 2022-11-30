## initiate VPC and it all config

##==============================VPC====================================================
resource "aws_vpc" "tutorial_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }

}
##=============================SUBNET====================================================
resource "aws_subnet" "tutorial_public_subnet" {
  vpc_id                  = aws_vpc.tutorial_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "dev-public"
  }
}
##================================IGW====================================================
resource "aws_internet_gateway" "tutorial_internet_gateway" {
  vpc_id = aws_vpc.tutorial_vpc.id
  tags = {
    Name = "dev-igw"
  }
}
##=================================RT====================================================
resource "aws_route_table" "tutorial_public_rt" {
  vpc_id = aws_vpc.tutorial_vpc.id
  tags = {
    Name = "dev_public_rt"
  }
}
##=============================ROUTE====================================================
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.tutorial_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tutorial_internet_gateway.id
}
##=======================TABLE ROUTE ASS================================================
resource "aws_route_table_association" "tutorial_public_assoc" {
  subnet_id      = aws_subnet.tutorial_public_subnet.id
  route_table_id = aws_route_table.tutorial_public_rt.id
}
##================================SG====================================================
resource "aws_security_group" "tutorial_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.tutorial_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
##============================KEY-PAIR===================================================
## created using sshkeygen -t ed22519
#### ed is one of eliptic curve aglorithm and  its algorithm have same level of secruity as RSA with siginificatnlay smaller keys.
resource "aws_key_pair" "tutorial_auth" {
  key_name   = "tutorialkey"
  public_key = file("~/.ssh/tutorialkey.pub")
}
##============================Launch Instance===================================================
resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_instance.id
  key_name               = aws_key_pair.tutorial_auth.key_name
  vpc_security_group_ids = [aws_security_group.tutorial_sg.id]
  subnet_id              = aws_subnet.tutorial_public_subnet.id
  user_data = file("userdata.tpl")

  tags = {
    Name = "dev-node"
  }

  provisioner "local-exec"{
    #${var.host} sign means whatever going happens on the var.host is going to be calculated dynamcally whenever the script is run
    #var.host_os default value located in variables.tf
    #.tfvars will overriden files that located in variables.tf
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname = self.public_ip,
      user = "ubuntu",
      identityfile = "~/.ssh/tutorialkey"
    })
    #dynamic intrepreter for conditional statement
    interpreter = var.host_os == "linux" ? ["bash","-c"]:["Powershell","-Command"]
  }
}



