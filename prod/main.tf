provider "aws" {
    region = "eu-west-2"
}


resource "aws_s3_bucket_website_configuration" "prod_website" {
  bucket = aws_s3_bucket.uthman_production.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read_policy" {
    bucket = aws_s3_bucket.uthman_production.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid       = "PublicReadGetObject"
                Effect    = "Allow"
                Principal = "*"
                Action    = "s3:GetObject"
                Resource  = "${aws_s3_bucket.uthman_production.arn}/*"
            }
        ]
    })
}

resource "aws_s3_object" "index" {
    bucket       = aws_s3_bucket.uthman_production.id
    key          = "index.html"
    content      = "<html><body><h1>WELCOME TO PRODUCTION</h1><p>This site is hosted on AWS S3 using Terraform.</p></body></html>"
    content_type = "text/html"
}

# CloudFront Distribution for production environment

resource "aws_cloudfront_distribution" "production_distribution" {
  origin {
    domain_name = aws_s3_bucket.uthman_production.bucket_regional_domain_name
    origin_id   = "productionS3Origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Production CloudFront Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    target_origin_id = "productionS3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100" # cheapest — North America, Europe

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "Production"
  }
}