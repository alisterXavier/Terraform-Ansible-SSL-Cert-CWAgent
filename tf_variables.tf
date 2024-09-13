variable "ACCESS_KEY" {
  type = string
}

variable "SECRET_ACCESS_KEY" {
  type = string
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  public_subnets = [
    { az : "us-east-1a", cidr_block : "10.0.0.0/21" }, { az : "us-east-1b", cidr_block : "10.0.8.0/21" }
  ]
  ansible_files = ["playbook.yml", "variable/variables.yml", "tasks/certbot.yml", "tasks/apache.yml", "tasks/cloudwatch.yml", "handler/main.yml"]
}
data "aws_caller_identity" "current" {}
