output "cicd_role_arn"      { value = aws_iam_role.cicd_deploy.arn }
output "auditor_role_arn"   { value = aws_iam_role.auditor.arn }
output "enforce_mfa_policy" { value = aws_iam_policy.enforce_mfa.arn }
