locals {
  # Collect all unique attribute names from primary keys and GSIs
  all_attributes = toset(compact(concat(
    [var.hash_key],
    var.range_key != null && var.range_key != "" ? [var.range_key] : [],
    [for gsi in var.global_secondary_indexes : gsi.hash_key],
    [for gsi in var.global_secondary_indexes : gsi.range_key if gsi.range_key != null && gsi.range_key != ""]
  )))
}

resource "aws_dynamodb_table" "this" {
  name                        = var.table_name
  billing_mode                = var.billing_mode
  hash_key                    = var.hash_key
  range_key                   = var.range_key
  stream_enabled              = var.stream_enabled
  stream_view_type            = var.stream_enabled ? var.stream_view_type : null
  deletion_protection_enabled = var.deletion_protection_enabled

  # All unique attributes (deduplicated from primary keys and GSIs)
  dynamic "attribute" {
    for_each = local.all_attributes
    content {
      name = attribute.value
      type = lookup(var.attribute_types, attribute.value, "S")
    }
  }

  # TTL configuration
  ttl {
    enabled        = var.ttl_enabled
    attribute_name = var.ttl_attribute_name
  }

  # Point-in-time recovery
  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  # Global secondary indexes
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = global_secondary_index.value.range_key
      projection_type = global_secondary_index.value.projection_type
    }
  }

  # Encryption
  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  # Replicas for global tables
  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region_name            = replica.value.region_name
      kms_key_arn            = replica.value.kms_key_arn
      point_in_time_recovery = var.point_in_time_recovery_enabled
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity
    ]
  }
}
