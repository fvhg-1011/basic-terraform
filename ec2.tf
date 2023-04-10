# data sources to get id of registered AMI  that going to be used in other resources
# make sure for every instance that applied by terraform using the same registered ami version
## depends on the region that going to be used 
data "aws_ami" "cobain_ami" {
  most_recent = true
  owners      = ["099720109477"]
  # decide specific ami version that going to use (in this case the most recent AMI) in the AMI names
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}


#key for ssh to ec2 instance
resource "aws_key_pair" "cobain_key" {
  key_name   = "kons_key"
  public_key = file("~/.ssh/cobain_key.pub")
}

#setup ec2 instance
resource "aws_instance" "cobain_instance" {
  instance_type          = "t3.micro"
  ami                    = data.aws_ami.cobain_ami.id
  key_name               = aws_key_pair.cobain_key.key_name
  vpc_security_group_ids = [aws_security_group.cobain_sg.id]
  subnet_id              = aws_subnet.cobain_public_subnet.id
  root_block_device {
    volume_size = 10
  }
  tags = {
    Name = "cobain-ec2"
  }
  provisioner "local-exec" {
    command = templatefile("linux-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/cobain_key"
    })
    # shell that are used
    interpreter = ["bash", "-c"]
  }
}

