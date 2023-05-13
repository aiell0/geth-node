output "instance_id" {
  value       = aws_instance.node.id
}

output "grafana_workspace_id" {
  value = aws_grafana_workspace.this.id
}

output "private_ip" {
  value = aws_instance.node.private_ip
}
