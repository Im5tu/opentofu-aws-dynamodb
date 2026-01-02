variable "table_name" {
  type        = string
  description = "Name of the DynamoDB table"
}

variable "billing_mode" {
  type        = string
  description = "Billing mode for the table (PROVISIONED or PAY_PER_REQUEST)"
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST"
  }
}

variable "hash_key" {
  type        = string
  description = "The attribute to use as the hash (partition) key"
  default     = "PK"
}

variable "range_key" {
  type        = string
  description = "The attribute to use as the range (sort) key"
  default     = "SK"
}

variable "stream_enabled" {
  type        = bool
  description = "Enable DynamoDB Streams"
  default     = true
}

variable "stream_view_type" {
  type        = string
  description = "Stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "Stream view type must be one of: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES"
  }
}

variable "deletion_protection_enabled" {
  type        = bool
  description = "Enable deletion protection for the table"
  default     = false
}

variable "point_in_time_recovery_enabled" {
  type        = bool
  description = "Enable point-in-time recovery"
  default     = true
}

variable "ttl_enabled" {
  type        = bool
  description = "Enable TTL"
  default     = true
}

variable "ttl_attribute_name" {
  type        = string
  description = "The name of the TTL attribute"
  default     = "DynamoTimeToLive"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key for encryption at rest (optional)"
  default     = null
}

variable "global_secondary_indexes" {
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = optional(string)
    projection_type = string
  }))
  description = "List of global secondary indexes"
  default     = []

  validation {
    condition = alltrue([
      for gsi in var.global_secondary_indexes :
      contains(["ALL", "KEYS_ONLY", "INCLUDE"], gsi.projection_type)
    ])
    error_message = "GSI projection_type must be ALL, KEYS_ONLY, or INCLUDE"
  }
}

variable "replica_regions" {
  type = list(object({
    region_name = string
    kms_key_arn = optional(string)
  }))
  description = "List of replica configurations with region-specific KMS keys"
  default     = []
}

variable "attribute_types" {
  type        = map(string)
  description = "Map of attribute names to their types (S=String, N=Number, B=Binary). Defaults to S if not specified."
  default     = {}

  validation {
    condition     = alltrue([for v in values(var.attribute_types) : contains(["S", "N", "B"], v)])
    error_message = "Attribute types must be one of: S (String), N (Number), or B (Binary)"
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the DynamoDB table"
  default     = {}
}
