provider "aws" {
    region = "eu-west-2"
}
# S3 website Configuration — points to existing bucket
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = "uthman-develop-2025"

  index_document {
    suffix = "index.html"
  }
}

# S3 Bucket Policy — public read access (plus GetObject if needed)
resource "aws_s3_bucket_policy" "public_read_policy" {
    bucket = "uthman-develop-2025"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid       = "PublicReadGetObject"
                Effect    = "Allow"
                Principal = "*"
                Action    = [
                    "s3:GetObject",
                    "s3:GetObjectVersion"
                ]
                Resource  = "arn:aws:s3:::uthman-develop-2025/*"            
         }
        ]
    })
}

# S3 Object (index.html)
resource "aws_s3_object" "index" {
    bucket       = "uthman-develop-2025"
    key          = "index.html"
    content      = "<html><body><h1>WELCOME TO DEVELOPMENT</h1><p>This site is hosted on AWS S3 using Terraform.</p> <p>I KNOW YOU WILL WORK HARD</p></body></html>"
    content_type = "text/html"
}
# CloudFront Distribution for development environment
resource "aws_cloudfront_distribution" "develop_distribution" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.website.website_endpoint
    origin_id   = "developmentS3Origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "development CloudFront Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    target_origin_id = "developmentS3Origin"

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
    Environment = "development"
  }
}

# Output the CloudFront URL for development environment
output "development_cloudfront_url" {
  description = "CloudFront URL for Development environment"
  value       = aws_cloudfront_distribution.develop_distribution.domain_name
}

# Output the CloudFront Distribution ID (for GitHub Actions cache invalidation)
output "development_cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.develop_distribution.id
}
