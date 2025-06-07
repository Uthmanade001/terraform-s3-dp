provider "aws" {
    region = "eu-west-2"
}

resource "aws_s3_bucket" "uthman_develop" {
    bucket = "uthman-develop-2025"
    force_destroy = true

    tags = {
        Name        = "uthman-develop-2025"
        Environment = "development"
    }
}

resource "aws_s3_bucket_website_configuration" "dev_website" {
  bucket = aws_s3_bucket.uthman_develop.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read_policy" {
    bucket = aws_s3_bucket.uthman_develop.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid       = "PublicReadGetObject"
                Effect    = "Allow"
                Principal = "*"
                Action    = "s3:GetObject"
                Resource  = "${aws_s3_bucket.uthman_develop.arn}/*"
            }
        ]
    })
}

resource "aws_s3_object" "index" {
    bucket       = aws_s3_bucket.uthman_develop.id
    key          = "index.html"
    content      = "<html><body><h1>WELCOME TO DEVELOPMENT</h1><p>This site is hosted on AWS S3 using Terraform.</p></body></html>"
    content_type = "text/html"
}