provider "aws" {
    region = "eu-west-2"
}

resource "aws_s3_bucket" "uthman_staging" {
    bucket = "uthman-staging-2025"
    force_destroy = true
    

    tags = {
        Name        = "uthman-staging-2025"
        Environment = "staging"
    }
}

resource "aws_s3_bucket_website_configuration" "dev_website" {
  bucket = aws_s3_bucket.uthman_staging.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read_policy" {
    bucket = aws_s3_bucket.uthman_staging.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid       = "PublicReadGetObject"
                Effect    = "Allow"
                Principal = "*"
                Action    = "s3:GetObject"
                Resource  = "${aws_s3_bucket.uthman_staging.arn}/*"
            }
        ]
    })
}

resource "aws_s3_object" "index" {
    bucket       = aws_s3_bucket.uthman_staging.id
    key          = "index.html"
    content      = "<html><body><h1>WELCOME TO STAGING</h1><p>This site is hosted on AWS S3 using Terraform.</p></body></html>"
    content_type = "text/html"
}