terraform {
  backend "s3" {}
}

provider "aws" {
  region = "${var.aws_region}"
}

provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}

resource "aws_s3_bucket" "site_bucket"  {
  bucket = "${var.app}-site-bucket--stage-${var.stage}"

  acl    = "public-read"

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.app}-site-bucket--stage-${var.stage}/*"
    }
  ]
}
EOF

  tags = {
    APP = "${var.app}"
    STAGE = "${var.stage}"
  }

  versioning {
    enabled = true
  }
  
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "null_resource" "upload_web_resouce" {
  provisioner  "local-exec" {
    command = "aws s3 sync ${var.directory} s3://${var.app}-site-bucket--stage-${var.stage}"
  }

  depends_on = ["aws_s3_bucket.site_bucket"]
}

# Certificate which is associated with Cloudfont must be create in us-east-1
resource "aws_acm_certificate" "certificate" {
  provider = "aws.virginia"
  
  domain_name       = "*.${var.root_domain}"
  validation_method = "DNS"

  subject_alternative_names = ["${var.root_domain}"]
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = "${aws_s3_bucket.site_bucket.bucket_regional_domain_name}"
    origin_id   = "${var.domain_name}"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.domain_name}"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = ["${var.domain_name}.${var.root_domain}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.certificate.arn}"
    ssl_support_method  = "sni-only"
  }

  depends_on= ["null_resource.upload_web_resouce"]
}

resource "aws_route53_zone" "zone" {
  name = "${var.root_domain}"
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
