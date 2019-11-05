provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "${var.app}-deployment-state-bucket--stage-${var.stage}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    APP   = "${var.app}"
    STAGE = "${var.stage}"
  }
}

resource "aws_dynamodb_table" "terraform_locked_tb" {
  name         = "${var.app}-lock-state-table--stage-${var.stage}"
  billing_mode = "PAY_PER_REQUEST"
  
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    APP = "${var.app}"
    STAGE = "${var.stage}"
  }
}
