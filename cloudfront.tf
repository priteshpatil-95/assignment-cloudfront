locals {
  s3_origin_id = aws_s3_bucket.demo_bucket.bucket_regional_domain_name
}

resource "aws_cloudfront_origin_access_identity" "new_identity" {

  # comment = "Some comment"

}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.demo_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id



    #  origin {
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.new_identity.cloudfront_access_identity_path
    }
    #   }

    #     s3_origin_config {
    #       origin_access_identity = "origin-access-identity/cloudfront/E5AHXXSCP7J2Q"
    #     }
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "Assignment demo"
  default_root_object = "index.html"

  #   logging_config {
  #     include_cookies = false
  #     bucket          = "mylogs.s3.amazonaws.com"
  #     prefix          = "myprefix"
  #   }

  #   aliases = ["mysite.example.com", "yoursite.example.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  #   ordered_cache_behavior {
  #     path_pattern     = "/content/immutable/*"
  #     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #     cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #     target_origin_id = local.s3_origin_id

  #     forwarded_values {
  #       query_string = false
  #       headers      = ["Origin"]

  #       cookies {
  #         forward = "none"
  #       }
  #     }

  #     min_ttl                = 0
  #     default_ttl            = 86400
  #     max_ttl                = 31536000
  #     compress               = true
  #     viewer_protocol_policy = "redirect-to-https"
  #   }

  #   # Cache behavior with precedence 1
  #   ordered_cache_behavior {
  #     path_pattern     = "/content/*"
  #     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #     cached_methods   = ["GET", "HEAD"]
  #     target_origin_id = local.s3_origin_id

  #     forwarded_values {
  #       query_string = false

  #       cookies {
  #         forward = "none"
  #       }
  #     }

  #     min_ttl                = 0
  #     default_ttl            = 3600
  #     max_ttl                = 86400
  #     compress               = true
  #     viewer_protocol_policy = "redirect-to-https"
  #   }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      #       locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


#Bucket Policy

resource "aws_s3_bucket_policy" "policy_attachment" {
  bucket = aws_s3_bucket.demo_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}