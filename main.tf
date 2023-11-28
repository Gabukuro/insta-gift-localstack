provider "aws" {
  region                      = "us-east-2"
  profile                     = "test-profile"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    es             = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    route53        = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

resource "aws_secretsmanager_secret" "aws" {
  name = "development.aws"
}
resource "aws_secretsmanager_secret_version" "aws" {
  secret_id     = aws_secretsmanager_secret.aws.id
  secret_string = <<EOF
{
  "sqs": {
    "insta-gift-api": {
      "analysisProfileQueuUrl": "http://localhost:4566/000000000000/profile-analysis-queue"
    }
  },
  "sns": {
    "insta-gift-api": {
      "analysisProfileEvents": "arn:aws:sns:us-east-2:000000000000:profile-analysis-events"
    }
  }
}
EOF
}


resource "aws_secretsmanager_secret" "database" {
  name = "development.database"
}
resource "aws_secretsmanager_secret_version" "database" {
  secret_id     = aws_secretsmanager_secret.database.id
  secret_string = <<EOF
{ 
  "insta-gift-api": "postgres://postgres:postgres@localhost:5432/insta-gift-api?sslmode=disable"
}
EOF
}

resource "aws_sqs_queue" "profile-analysis-queue" {
  name                      = "profile-analysis-queue"
  message_retention_seconds  = "345600" //4 Days
  max_message_size           = "262144" //256 KB
  visibility_timeout_seconds = "180"    //3 minutes
}

resource "aws_sqs_queue_policy" "profile-analysis-queue" {
  depends_on = [aws_sqs_queue.profile-analysis-queue]
  queue_url = aws_sqs_queue.profile-analysis-queue.id

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "Sid1570037255435",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "SQS:SendMessage",
      "Resource": "arn:aws:sqs:us-east-2:000000000000:profile-analysis-queue",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "arn:aws:sns:us-east-2:000000000000:profile-analysis-events"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic" "profile-analysis-events" {
  name                                     = "profile-analysis-events"
  sqs_failure_feedback_role_arn            = "arn:aws:iam::000000000000:role/SNSFailureFeedback"
  sqs_success_feedback_role_arn            = "arn:aws:iam::000000000000:role/SNSSuccessFeedback"
  application_success_feedback_sample_rate = "100"
  http_success_feedback_sample_rate        = "100"
  lambda_success_feedback_sample_rate      = "100"
  sqs_success_feedback_sample_rate         = "10"
  policy                                   = <<EOF
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish",
        "SNS:Receive"
      ],
      "Resource": "arn:aws:sns:us-east-2:000000000000:profile-analysis-events",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "000000000000"
        }
      }
    }
  ]
}
EOF
}

resource "aws_sns_topic_subscription" "profile-analysis-queue" {
  depends_on = [aws_sns_topic.profile-analysis-events]
  topic_arn                       = aws_sns_topic.profile-analysis-events.arn
  protocol                        = "sqs"
  endpoint                        = "arn:aws:sqs:us-east-2:000000000000:profile-analysis-queue"
  endpoint_auto_confirms          = false
  confirmation_timeout_in_minutes = "1"
  raw_message_delivery            = true
}
