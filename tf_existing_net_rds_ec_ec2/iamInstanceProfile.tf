# IAM Role

resource "aws_iam_role" "airflow_instance" {

  name               = "${var.prefix}_instance"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM S3 Role Policy

resource "aws_iam_role_policy" "airflow_s3" {
  name = "${var.prefix}_s3"
  role = aws_iam_role.airflow_instance.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:ListBucket"
            ],
            "Resource": [
              "${aws_s3_bucket.s3_airflow_bucket.arn}",
              "${aws_s3_bucket.s3_airflow_log_bucket.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObject"
            ],
            "Resource": [
              "${aws_s3_bucket.s3_airflow_bucket.arn}/*",
              "${aws_s3_bucket.s3_airflow_log_bucket.arn}/*"
            ]
        }

    ]
}
EOF
}

# IAM Logs Role Policy

resource "aws_iam_role_policy" "airflow_logs" {
  name = "${var.prefix}_logs"
  role = aws_iam_role.airflow_instance.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        "Resource": [
          "arn:aws:logs:*:*:*"
        ]
      }
   ]
}
EOF
}

# IAM Secrets Manager Role Policy

resource "aws_iam_role_policy" "airflow_secrets" {
  name = "${var.prefix}_secrets"
  role = aws_iam_role.airflow_instance.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetSecretValue"
        ],
        "Resource": [
          "${aws_secretsmanager_secret.airflow_sm_secret.id}"
        ]
      }
   ]
}
EOF
}


# IAM Instance Profile

resource "aws_iam_instance_profile" "airflow_s3_instance_profile" {
  name = "${var.prefix}_instance_profile"
  role = aws_iam_role.airflow_instance.name
}

# SSM Policy for cloudwatch logs

resource "aws_iam_role_policy_attachment" "airflow_ssm_managed_policy_attachment" {
  role       = aws_iam_role.airflow_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# IAM Bastion Role

resource "aws_iam_role" "airflow_bastion" {

  name               = "${var.prefix}_bastion"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


# SSM Policy for cloudwatch logs

resource "aws_iam_role_policy_attachment" "airflow_bastion_ssm_mgd_policy_attachment" {
  role       = aws_iam_role.airflow_bastion.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
