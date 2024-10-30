# S3 Globally Unit Bucket
resource "aws_s3_bucket" "nextjs_bucket" {
  bucket = "ridly-terraformnextjs"
  
  tags = {
    Name    = "staticbucket"
  }
}

# Ownership Control
resource "aws_s3_bucket_ownership_controls" "nextjs_bucket_ownership_controls" {
  bucket = aws_s3_bucket.nextjs_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "nextj_bucket_public_access_block" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
  
}

#Bucket ACL

resource "s3_bucket_acl" "nextjs_bucket_acl" {

  depends_on = [ 
    aws_s3_bucket_ownership_controls.nextjs_bucket_ownership_controls,
    aws_s3_bucket_public_access_block.nextj_bucket_public_access_block
     ]
  bucket = aws_s3_bucket.nextjs_bucket.id
  acl = "public-read"
  
}

# Bucket Policy

resource "aws_s3_bucket_policy" "nextjs_bucket_policy" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.nextjs_bucket.arn}/*"
      }
    ]
  })
}

# Define Origin Access Identity 

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {

  comment = "OAI for Next.JS portfolio site"  
}

# Cloudfront Distribution

resource "aws_cloudfront_distribution" "nextjs_distribution" {
  origin {
    domain_name = aws_s3_bucket.nextjs_bucket.bucket_regional_domain_name
    origin_id = "S3-nextjs-portfolio-bucket"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path    
    }
  }
  
  enabled = true #serve content right away; if false then will not serve
  is_ipv6_enabled = true #for dual stack
  comment = "Next.js portfolio site"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    target_origin_id       = "S3-nextjs-portfolio-bucket"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
            }
    }

    viewer_protocol_policy  = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
 
  viewer_certificate {
    cloudfront_default_certificate = true #tells cloudfront to use its default SSL/TLS certificate
}
}

  

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  index_document {
    suffix = "index_document.html"
  }

  error_document {
    key = "error_document.html"
  }
     
    
  
  }