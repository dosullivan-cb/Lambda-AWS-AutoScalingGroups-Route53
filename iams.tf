resource "aws_iam_role_policy" "ASGNotifyPolicy_READ" {
  name                        = "ASGNotifyPolicy_READ"

  role                        = "${aws_iam_role.ASGNotify.id}"
  policy                      = <<ASG_NOTIFY_POLICY_READ
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "iam:GetInstanceProfile",
        "autoscaling:DescribeTags",
        "autoscaling:DescribeAutoScalingGroups",
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
ASG_NOTIFY_POLICY_READ
}

# Allow `ASGNotify` to assume the `ASGNotify` role in Validation
resource "aws_iam_role_policy" "ASGNotifyPolicy_ASSUME_ROLE_REMOTE_ACCOUNT" {
  name                        = "ASGNotifyPolicy_ASSUME_ROLE_REMOTE_ACCOUNT"

  role                        = "${aws_iam_role.ASGNotify.id}"
  policy                      = <<ASG_NOTIFY_POLICY_ASSUME_ROLE_REMOTE_ACCOUNT
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": [
        "arn:aws:iam::<REMOTE_ACCOUNT_ID>:role/ASGNotify"
    ]
  }
}
ASG_NOTIFY_POLICY_ASSUME_ROLE_REMOTE_ACCOUNT
}

resource "aws_iam_role_policy" "ASGNotifyPolicy_DECRYPT" {
  name                        = "ASGNotifyPolicy_DECRYPT"

  role                        = "${aws_iam_role.ASGNotify.id}"
  policy                      = <<ASG_NOTIFY_POLICY_DECRYPT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "${aws_kms_key.lambda-slack.arn}"
    }
  ]
}
ASG_NOTIFY_POLICY_DECRYPT
}

resource "aws_iam_role_policy" "ASGNotifyPolicy_WRITE_LOG" {
  name                        = "ASGNotifyPolicy_WRITE_LOG"

  role                        = "${aws_iam_role.ASGNotify.id}"
  policy                      = <<ASG_NOTIFY_POLICY_WRITE_LOG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/autoscaling_event_update_route53*"
    }
  ]
}
ASG_NOTIFY_POLICY_WRITE_LOG
}

# => Resource arn:aws:route53:eu-west-1:<LOCAL_ACCOUNT_ID>:hostedzone/* can not contain region information.
# => Resource arn:aws:route53::<LOCAL_ACCOUNT_ID>:hostedzone/* cannot contain an account id.
resource "aws_iam_role_policy" "ASGNotifyPolicy_WRITE_R53" {
  name                        = "ASGNotifyPolicy_WRITE_R53"

  role                        = "${aws_iam_role.ASGNotify.id}"
  policy                      = <<ASG_NOTIFY_POLICY_WRITE_R53
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    }
  ]
}
ASG_NOTIFY_POLICY_WRITE_R53
}

# Needed to update the Name tag with the individual number.
resource "aws_iam_role_policy" "ASGNotifyPolicy_WRITE_EC2" {
  name                        = "ASGNotifyPolicy_WRITE_EC2"

  role                        = "${aws_iam_role.ASGNotify.id}"
  policy                      = <<ASG_NOTIFY_POLICY_WRITE_EC2
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
ASG_NOTIFY_POLICY_WRITE_EC2
}

resource "aws_iam_role_policy" "ASGNotifyPolicy_WRITE_VPC" {
  name                        = "ASGNotifyPolicy_WRITE_VPC"

  role                        = "${aws_iam_role.ASGNotify.id}"
  policy                      = <<ASG_NOTIFY_POLICY_WRITE_VPC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces"
      ],
      "Resource": "*"
    }
  ]
}
ASG_NOTIFY_POLICY_WRITE_VPC
}

resource "aws_iam_role" "ASGNotify" {
  name                        = "ASGNotify"
  assume_role_policy          = <<ASG_NOTIFY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "lambda.amazonaws.com",
          "apigateway.amazonaws.com"
        ]
      }
    }
  ]
}
ASG_NOTIFY
}
