#!/usr/bin/env python3
"""
AWS S3 & CloudFront Deployment Automation Script
Uploads website assets and creates CloudFront cache invalidations.
"""

import os
import sys
import mimetypes
import boto3

def deploy(bucket_name, distribution_id, website_dir="./website"):
    s3 = boto3.client("s3")
    cloudfront = boto3.client("cloudfront")

    print(f"Deploying assets from '{website_dir}' to S3 bucket '{bucket_name}'...")

    for root, _, files in os.walk(website_dir):
        for file in files:
            local_path = os.path.join(root, file)
            relative_path = os.path.relpath(local_path, website_dir).replace("\\", "/")
            mime_type, _ = mimetypes.guess_type(local_path)
            content_type = mime_type or "application/octet-stream"

            cache_control = "max-age=0, must-revalidate" if file.endswith(".html") else "max-age=31536000, immutable"

            print(f"  Uploading: {relative_path} ({content_type})")
            s3.upload_file(
                local_path,
                bucket_name,
                relative_path,
                ExtraArgs={
                    "ContentType": content_type,
                    "CacheControl": cache_control
                }
            )

    print(f"\nCreating CloudFront invalidation for distribution '{distribution_id}'...")
    invalidation = cloudfront.create_invalidation(
        DistributionId=distribution_id,
        InvalidationBatch={
            "Paths": {
                "Quantity": 1,
                "Items": ["/*"]
            },
            "CallerReference": str(os.urandom(16).hex())
        }
    )
    inv_id = invalidation["Invalidation"]["Id"]
    print(f"Invalidation triggered successfully: {inv_id}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python deploy.py <BUCKET_NAME> <DISTRIBUTION_ID>")
        sys.exit(1)
    deploy(sys.argv[1], sys.argv[2])
