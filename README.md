# OpenTofu AWS DynamoDB Module

Creates a DynamoDB table with support for global secondary indexes, global tables (multi-region replication), TTL, point-in-time recovery, and server-side encryption. Streams are enabled by default for change data capture.

## Usage

### Basic Table with Partition Key Only

```hcl
module "simple_table" {
  source = "git::https://github.com/im5tu/opentofu-aws-dynamodb.git?ref=main"

  table_name = "my-table"
  hash_key   = "id"
  range_key  = null

  tags = {
    Environment = "staging"
  }
}
```

### Table with Sort Key and GSI

```hcl
module "table_with_gsi" {
  source = "git::https://github.com/im5tu/opentofu-aws-dynamodb.git?ref=main"

  table_name = "orders"
  hash_key   = "PK"
  range_key  = "SK"

  global_secondary_indexes = [
    {
      name            = "GSI1"
      hash_key        = "GSI1PK"
      range_key       = "GSI1SK"
      projection_type = "ALL"
    },
    {
      name            = "ByStatus"
      hash_key        = "status"
      projection_type = "KEYS_ONLY"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Global Table with Replicas

```hcl
module "global_table" {
  source = "git::https://github.com/im5tu/opentofu-aws-dynamodb.git?ref=main"

  table_name = "global-config"
  hash_key   = "PK"
  range_key  = "SK"

  kms_key_arn = aws_kms_key.primary.arn

  replica_regions = [
    {
      region_name = "eu-west-1"
      kms_key_arn = aws_kms_key.eu_west_1.arn
    },
    {
      region_name = "ap-southeast-1"
      kms_key_arn = aws_kms_key.ap_southeast_1.arn
    }
  ]

  deletion_protection_enabled = true

  tags = {
    Environment = "production"
  }
}
```

### Using Non-String Attribute Types

```hcl
module "table_with_numbers" {
  source = "git::https://github.com/im5tu/opentofu-aws-dynamodb.git?ref=main"

  table_name = "metrics"
  hash_key   = "device_id"
  range_key  = "timestamp"

  attribute_types = {
    device_id = "S"
    timestamp = "N"
    sensor_id = "N"
  }

  global_secondary_indexes = [
    {
      name            = "BySensor"
      hash_key        = "sensor_id"
      range_key       = "timestamp"
      projection_type = "ALL"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| opentofu | >= 1.9 |
| aws | ~> 6 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| table_name | Name of the DynamoDB table | `string` | n/a | yes |
| hash_key | The attribute to use as the hash (partition) key | `string` | `"PK"` | no |
| range_key | The attribute to use as the range (sort) key | `string` | `"SK"` | no |
| billing_mode | Billing mode for the table (PROVISIONED or PAY_PER_REQUEST) | `string` | `"PAY_PER_REQUEST"` | no |
| stream_enabled | Enable DynamoDB Streams | `bool` | `true` | no |
| stream_view_type | Stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES) | `string` | `"NEW_AND_OLD_IMAGES"` | no |
| deletion_protection_enabled | Enable deletion protection for the table | `bool` | `false` | no |
| point_in_time_recovery_enabled | Enable point-in-time recovery | `bool` | `true` | no |
| ttl_enabled | Enable TTL | `bool` | `true` | no |
| ttl_attribute_name | The name of the TTL attribute | `string` | `"DynamoTimeToLive"` | no |
| kms_key_arn | ARN of the KMS key for encryption at rest (optional, uses AWS managed key if null) | `string` | `null` | no |
| global_secondary_indexes | List of global secondary indexes | `list(object({name=string, hash_key=string, range_key=optional(string), projection_type=string}))` | `[]` | no |
| replica_regions | List of replica configurations with region-specific KMS keys | `list(object({region_name=string, kms_key_arn=optional(string)}))` | `[]` | no |
| attribute_types | Map of attribute names to their types (S=String, N=Number, B=Binary). Defaults to S if not specified. | `map(string)` | `{}` | no |
| tags | Tags to apply to the DynamoDB table | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| table_id | The ID of the DynamoDB table |
| table_name | The name of the DynamoDB table |
| table_arn | The ARN of the DynamoDB table |
| stream_arn | The ARN of the DynamoDB stream |
| stream_label | The label of the DynamoDB stream |

## Development

### Validation

This module uses GitHub Actions for validation:

- **Format check**: `tofu fmt -check -recursive`
- **Validation**: `tofu validate`
- **Security scanning**: Checkov, Trivy

### Local Development

```bash
# Format code
tofu fmt -recursive

# Validate
tofu init -backend=false
tofu validate
```

## License

MIT License - see [LICENSE](LICENSE) for details.
