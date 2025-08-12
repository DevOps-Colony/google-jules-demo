# terraform/modules/dynamodb/variables.tf

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}
