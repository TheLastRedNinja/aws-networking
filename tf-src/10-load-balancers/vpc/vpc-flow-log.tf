#####################################################
#### Resources for VPC Flow Logs sent to Cloudwatch
#####################################################
#
#resource "aws_cloudwatch_log_group" "web-vpc-default-log-group" {
#  name              = "denis-web-vpc-default-log-group"
#  retention_in_days = 7
#  tags = merge(local.default_tags, {
#    Name = "denis-web-vpc-default-log-group"
#  })
#}
#
#data "aws_iam_policy_document" "allow-vpc-flow-logs-service-to-assume-roles" {
#  statement {
#    effect = "Allow"
#
#    principals {
#      type        = "Service"
#      identifiers = ["vpc-flow-logs.amazonaws.com"]
#    }
#
#    actions = ["sts:AssumeRole"]
#  }
#}
#
#resource "aws_iam_role" "web-vpc-flow-logs-role" {
#  name               = "denis-web-vpc-default-flow-logs-role"
#  assume_role_policy = data.aws_iam_policy_document.allow-vpc-flow-logs-service-to-assume-roles.json
#  tags = merge(local.default_tags, {
#    Name = "denis-web-vpc-default-flow-logs-role"
#  })
#}
#
#data "aws_iam_policy_document" "allow-create-flow-logs" {
#  statement {
#    effect = "Allow"
#
#    actions = [
#      "logs:CreateLogGroup",
#      "logs:CreateLogStream",
#      "logs:PutLogEvents",
#      "logs:DescribeLogGroups",
#      "logs:DescribeLogStreams",
#    ]
#
#    resources = ["*"]
#  }
#}
#
#resource "aws_iam_role_policy" "allow-role-to-create-flow-logs" {
#  name   = "denis-allow-role-to-create-flow-logs"
#  role   = aws_iam_role.web-vpc-flow-logs-role.id
#  policy = data.aws_iam_policy_document.allow-create-flow-logs.json
#}
#
#resource "aws_flow_log" "web-vpc-flow-log-accepted-traffic" {
#  vpc_id = aws_vpc.denis-network-public.id
#
#  traffic_type             = "ACCEPT"
#  max_aggregation_interval = "600"
#  log_destination_type     = "cloud-watch-logs"
#  log_destination          = aws_cloudwatch_log_group.web-vpc-default-log-group.arn
#  iam_role_arn             = aws_iam_role.web-vpc-flow-logs-role.arn
#
#  tags = merge(local.default_tags, {
#    Name = "denis-web-vpc-default-cloudwatch-flow-log-for-accepted-traffic"
#  })
#}
#
#resource "aws_flow_log" "web-vpc-flow-log-rejected-traffic" {
#  vpc_id = aws_vpc.denis-network-public.id
#
#  traffic_type             = "REJECT"
#  max_aggregation_interval = "600"
#  log_destination_type     = "cloud-watch-logs"
#  log_destination          = aws_cloudwatch_log_group.web-vpc-default-log-group.arn
#  iam_role_arn             = aws_iam_role.web-vpc-flow-logs-role.arn
#
#  tags = merge(local.default_tags, {
#    Name = "denis-web-vpc-default-cloudwatch-flow-log-for-rejected-traffic"
#  })
#}
#
#####################################################
#### Resources for VPC Flow Logs sent to S3
#####################################################
#
#resource "aws_s3_bucket" "web-vpc-flow-logs" {
#  bucket = "denis-murphy-web-vpc-flow-logs"
#
#  tags = merge(local.default_tags, {
#    Name = "denis-murphy-web-vpc-flow-logs"
#  })
#}
#
#resource "aws_flow_log" "web-vpc-s3-flow-log-all-traffic" {
#  vpc_id = aws_vpc.denis-network-public.id
#
#  traffic_type             = "ALL"
#  max_aggregation_interval = "600"
#  log_destination_type     = "s3"
#  log_destination          = aws_s3_bucket.web-vpc-flow-logs.arn
#
#  tags = merge(local.default_tags, {
#    Name = "denis-web-vpc-default-s3-flow-log-for-all-traffic"
#  })
#}
#
## [version, accountid ,interfaceid, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes > 200000, start ,end, action, logstatus]