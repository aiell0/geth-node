output "grafana_workspace_id" {
  value = aws_grafana_workspace.this.id
}

output "grafana_workspace_endpoint" {
  value = aws_grafana_workspace.this.endpoint
}

output "private_ip" {
  value = aws_instance.node.private_ip
}

output "public_ip" {
  value = aws_instance.node.public_ip
}
