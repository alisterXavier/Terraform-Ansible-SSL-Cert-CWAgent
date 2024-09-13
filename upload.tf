resource "null_resource" "upload_ansible_files" {
  for_each = toset(local.ansible_files)

  provisioner "file" {
    source      = "Terraform Ansible/ansible/${each.value}"
    destination = "/home/ansible/${each.value}"

    connection {
      type     = "ssh"
      host     = aws_instance.CloudOpsInstance.public_ip
      user     = "ansible"
      password = "typewriter"
    }
  }
}
resource "null_resource" "upload_cloudwatch_file" {
  provisioner "file" {
    source      = "Terraform Ansible/cloudwatch_config/cloudwatch_config.json"
    destination = "/home/ansible/cloudwatch_agent/config.json"

    connection {
      type     = "ssh"
      host     = aws_instance.CloudOpsInstance.public_ip
      user     = "ansible"
      password = "typewriter"
    }
  }
}
