################################################################################
# IAM Module — ars-devsecops
# Least-privilege IAM roles, policies, and MFA enforcement
# Based on real-world patterns from financial-domain client hardening
################################################################################

# ── CI/CD Deployment Role ─────────────────────────────────────────────────────
resource "aws_iam_role" "cicd_deploy" {
  name        = "${var.name}-cicd-deploy-role"
  description = "Least-privilege role for CI/CD pipeline deployments"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "codepipeline.amazonaws.com" }
        Action    = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = var.trusted_account_arns
        }
        Action    = "sts:AssumeRole"
        Condition = {
          Bool = { "aws:MultiFactorAuthPresent" = "true" }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "cicd_deploy" {
  name        = "${var.name}-cicd-deploy-policy"
  description = "Permissions for CI/CD deployments — least privilege"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2DeployPermissions"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:StartInstanceRefresh",
          "autoscaling:DescribeInstanceRefreshes"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECSDeployPermissions"
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:ListTasks",
          "ecs:DescribeTasks"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRPushPermissions"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3ArtifactAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::${var.artifact_bucket_name}/*"
      },
      {
        Sid    = "SecretsManagerReadOnly"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.name}/*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cicd_deploy" {
  role       = aws_iam_role.cicd_deploy.name
  policy_arn = aws_iam_policy.cicd_deploy.arn
}

# ── MFA Enforcement Policy ────────────────────────────────────────────────────
resource "aws_iam_policy" "enforce_mfa" {
  name        = "${var.name}-enforce-mfa"
  description = "Forces MFA for all actions except MFA management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowViewAccountInfo"
        Effect = "Allow"
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:GetAccountSummary",
          "iam:ListVirtualMFADevices"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowManageOwnMFA"
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice"
        ]
        Resource = [
          "arn:aws:iam::*:mfa/$${aws:username}",
          "arn:aws:iam::*:user/$${aws:username}"
        ]
      },
      {
        Sid    = "DenyAllExceptMFASetupWithoutMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# ── Read-Only Auditor Role ────────────────────────────────────────────────────
resource "aws_iam_role" "auditor" {
  name        = "${var.name}-auditor-role"
  description = "Read-only access for security audits and compliance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = var.trusted_account_arns }
      Action    = "sts:AssumeRole"
      Condition = {
        Bool = { "aws:MultiFactorAuthPresent" = "true" }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "auditor_readonly" {
  role       = aws_iam_role.auditor.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "auditor_security" {
  role       = aws_iam_role.auditor.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}
