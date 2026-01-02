output "table_id" {
  value       = aws_dynamodb_table.this.id
  description = "The ID of the DynamoDB table"
}

output "table_name" {
  value       = aws_dynamodb_table.this.name
  description = "The name of the DynamoDB table"
}

output "table_arn" {
  value       = aws_dynamodb_table.this.arn
  description = "The ARN of the DynamoDB table"
}

output "stream_arn" {
  value       = try(aws_dynamodb_table.this.stream_arn, null)
  description = "The ARN of the DynamoDB stream"
}

output "stream_label" {
  value       = try(aws_dynamodb_table.this.stream_label, null)
  description = "The label of the DynamoDB stream"
}
