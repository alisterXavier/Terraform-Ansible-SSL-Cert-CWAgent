resource "aws_key_pair" "key_pair" {
  key_name   = "testtest"
  public_key = file("./Terraform Ansible/my_new_key.pub")
}

resource "aws_instance" "CloudOpsInstance" {
  ami                         = "ami-0e86e20dae9224db8"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnets[1].id
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.security_group.id]
  user_data = templatefile("./Terraform Ansible/scripts/userdata.sh", {
    instance1             = aws_instance.CloudOpsInstance1.private_ip
    instance2             = aws_instance.CloudOpsInstance2.private_ip
    aws_secret_access_key = var.SECRET_ACCESS_KEY
    aws_access_key_id     = var.ACCESS_KEY
    USER                  = "ansible"
    PASSWORD              = "typewriter"
  })
  depends_on = [aws_instance.CloudOpsInstance1, aws_instance.CloudOpsInstance2]
  tags = {
    Name = "Master"
  }
}

resource "aws_instance" "CloudOpsInstance1" {
  ami                         = "ami-0e86e20dae9224db8"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnets[1].id
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.security_group.id]
  iam_instance_profile        = aws_iam_instance_profile.EC2Profile.name
  user_data = templatefile("./Terraform Ansible/scripts/worker.sh", {
    aws_secret_access_key = var.SECRET_ACCESS_KEY
    aws_access_key_id     = var.ACCESS_KEY
  })
   tags = {
    Name = "Worker"
  }
}

resource "aws_instance" "CloudOpsInstance2" {
  ami                         = "ami-0e86e20dae9224db8"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnets[1].id
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.security_group.id]
  iam_instance_profile        = aws_iam_instance_profile.EC2Profile.name
  user_data = templatefile("./Terraform Ansible/scripts/worker.sh", {
    aws_secret_access_key = var.SECRET_ACCESS_KEY
    aws_access_key_id     = var.ACCESS_KEY
  })
  tags = {
    Name = "Worker"
  }
}

resource "aws_iam_instance_profile" "EC2Profile" {
  role = aws_iam_role.EC2Role.name
}
resource "aws_iam_role" "EC2Role" {
  name = "EC2Role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}
resource "aws_iam_role_policy_attachment" "CloudwatchLogPolicyAttachment" {
  role       = aws_iam_role.EC2Role.name
  policy_arn = aws_iam_policy.CloudwatchLogPolicy.arn
}
resource "aws_iam_policy" "CloudwatchLogPolicy" {
  name = "CloudwatchLogPolicy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "Statement1",
          "Effect" : "Allow",
          "Action" : [
            "logs:*"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    }
  )
}
output "ec2_Ipaddress_1" {
  value = aws_instance.CloudOpsInstance1.private_ip
}
output "ec2_Ipaddress_2" {
  value = aws_instance.CloudOpsInstance2.private_ip
}
