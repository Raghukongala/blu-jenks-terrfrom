output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "iam_role_arn" {
  description = "Paste this into projct/terraform.tfvars as jenkins_iam_role_arn"
  value       = aws_iam_role.jenkins.arn
}

output "ssh_command" {
  value = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.jenkins.public_ip}"
}
