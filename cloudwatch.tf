resource "aws_cloudwatch_log_group" "SSH-Failed-Auth" {
  name = "SSH-Failed-Auth"
}
resource "aws_cloudwatch_log_metric_filter" "SSH_Failed_Log" {
  name           = "SSH Failed Log"
  pattern        = "?'authentication failures' ?'Failed password'"
  log_group_name = aws_cloudwatch_log_group.SSH-Failed-Auth.name
  metric_transformation {
    name      = "EC2_Failed_Auth"
    namespace = "SSHLogMetrics"
    value     = 1
  }
}
resource "aws_cloudwatch_metric_alarm" "SSH-Failed-Auth" {
  alarm_name          = "primary_log_check_metric_alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1

  metric_name = "SSH_Failed_Log"
  namespace   = "SSHLogMetrics"
  period      = 60
  statistic   = "Minimum"
  threshold   = 1
}
