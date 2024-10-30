resource "aws_s3_bucket" "staticbucket" {
  bucket = "ridly-terraformnextjs"
  
  tags = {
    Name    = "staticbucket"
  }
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.staticbucket.id

  index_document {
    suffix = "index_document.html"
  }

  error_document {
    key = "error_document.html"
  }
     
    
  
  }
