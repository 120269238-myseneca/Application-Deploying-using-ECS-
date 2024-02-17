resource "aws_cloudwatch_log_group" "cloudwatch_logs" {
  name = "cloudwatch-log-group"

}

resource "aws_cloudwatch_log_stream" "todo_container_cloudwatch_logstream" {
  name           = "cloudwatch-log-stream"
  log_group_name = aws_cloudwatch_log_group.cloudwatch_logs.name
}