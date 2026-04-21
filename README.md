# 🏗️ aws-terraform-modules

> Production-grade, reusable Terraform modules for AWS infrastructure — by [@ars-devsecops](https://github.com/ars-devsecops)

## 📦 Modules

| Module | Description | Resources |
|--------|-------------|-----------|
| [vpc](./modules/vpc) | VPC with public/private subnets, NAT, Flow Logs | VPC, Subnets, IGW, NAT GW, Route Tables |
| [ec2-asg](./modules/ec2-asg) | EC2 Launch Template + Auto Scaling Group | ASG, LT, IAM Role, CloudWatch Alarms |
| [alb](./modules/alb) | ALB with Blue/Green target groups | ALB, Blue TG, Green TG, Listeners |
| [iam](./modules/iam) | Least-privilege IAM roles + MFA enforcement | CI/CD Role, Auditor Role, MFA Policy |
| [rds](./modules/rds) | Encrypted RDS with Secrets Manager | RDS, Subnet Group, Secrets Manager |
| [s3](./modules/s3) | Secure S3 with versioning + lifecycle | S3 Bucket, Policies, Encryption |

## 🚀 Quick Start

```hcl
module "vpc" {
  source = "github.com/ars-devsecops/aws-terraform-modules//modules/vpc"

  name                 = "my-app"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["ap-south-1a", "ap-south-1b"]
  enable_nat_gateway   = true
  enable_flow_logs     = true

  tags = {
    Project     = "my-app"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## 🔐 Security Defaults

All modules follow these security principles:

- ✅ **Encryption at rest** — EBS, RDS, S3 all encrypted by default
- ✅ **IMDSv2 enforced** — No IMDSv1 on EC2 instances
- ✅ **MFA enforcement** — IAM policies require MFA for human access
- ✅ **Least privilege** — All IAM roles scoped to minimum required permissions
- ✅ **No hardcoded credentials** — Secrets Manager integration throughout
- ✅ **VPC Flow Logs** — Enabled by default for network auditing
- ✅ **S3 public access blocked** — All buckets block public access by default
- ✅ **HTTPS enforced** — S3 bucket policies deny HTTP requests

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws provider | >= 5.0 |

## 🏷️ Tagging Convention

```hcl
tags = {
  Project     = "project-name"
  Environment = "production"   # production / staging / dev 
  ManagedBy   = "terraform"
  Owner       = "devops-team"
  CostCenter  = "engineering"
}
```

## 📁 Structure

```
aws-terraform-modules/
├── modules/
│   ├── vpc/          # main.tf, variables.tf, outputs.tf
│   ├── ec2-asg/
│   ├── alb/
│   ├── iam/
│   ├── rds/
│   └── s3/
├── examples/
│   ├── basic-vpc/
│   └── ecs-cluster/
└── .github/
    └── workflows/
        └── terraform-validate.yml
```

## 🤝 Author

**Amol Shinde** · Cloud & DevOps Engineer · AWS Security Specialist  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat-square&logo=linkedin&logoColor=white)](https://linkedin.com/in/amol-shinde-profile)
