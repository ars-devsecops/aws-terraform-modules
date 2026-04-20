output "asg_name"              { value = aws_autoscaling_group.this.name }
output "launch_template_id"    { value = aws_launch_template.this.id }
output "ec2_security_group_id" { value = aws_security_group.ec2.id }
output "iam_role_arn"          { value = aws_iam_role.ec2.arn }
