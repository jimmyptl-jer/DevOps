# Create an IAM User
resource "aws_iam_user" "developer_user" {
  name = "developer-user"
  path = "/"
  tags = {
    Environment = "Development"
    Team        = "Backend"
  }
}

# Attach an Inline Policy to the User
resource "aws_iam_user_policy" "developer_policy" {
  name = "developer-inline-policy"
  user = aws_iam_user.developer_user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:*",
          "s3:*",
          "lambda:*",
          "dynamodb:*",
          "rds:*",
          "cloudwatch:*",
          "xray:*",
          "iam:PassRole",
          "codepipeline:*",
          "codebuild:*",
          "codedeploy:*",
          "ecr:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Deny",
        Action = [
          "iam:Create*",
          "iam:Delete*",
          "iam:Update*"
        ],
        Resource = "*"
      }
    ]
  })
}

# (Optional) Create an Access Key for the IAM User
resource "aws_iam_access_key" "developer_access_key" {
  user = aws_iam_user.developer_user.name
}

output "access_key_id" {
  value = aws_iam_access_key.developer_access_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.developer_access_key.secret
  sensitive = true
}
