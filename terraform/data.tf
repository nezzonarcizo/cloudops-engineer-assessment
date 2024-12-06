data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "arn:aws:secretsmanager:us-east-1:089350267643:secret:db_password-b6QWFM"
}

data "aws_acm_certificate" "nimbus" {
  domain = "*.4nimbus.com"
  statuses = ["ISSUED"]
  most_recent = true
}
