variable "bucket_name" {
  description = "name of the s3 bucket"
  type        = string
}

variable "region" {
    description = "AWS region where the S3 bucket is located"
    type        = string
    default    = "eu-west-2"
}