#!/usr/bin/env bash
# ==============================================================================
# Automated S3 Sync & CloudFront Cache Invalidation Script
# ==============================================================================
set -euo pipefail

BUCKET_NAME="${1:-}"
DISTRIBUTION_ID="${2:-}"

if [[ -z "$BUCKET_NAME" || -z "$DISTRIBUTION_ID" ]]; then
    echo "Usage: ./deploy.sh <S3_BUCKET_NAME> <CLOUDFRONT_DISTRIBUTION_ID>"
    exit 1
fi

echo "=========================================================="
echo " Starting Website Deployment to AWS"
echo " Target S3 Bucket:       $BUCKET_NAME"
echo " CloudFront Dist ID:     $DISTRIBUTION_ID"
echo "=========================================================="

# 1. Sync Website files to S3
echo "[1/2] Syncing static assets to S3..."
aws s3 sync ./website "s3://${BUCKET_NAME}" \
    --delete \
    --cache-control "public, max-age=31536000, immutable" \
    --exclude "*.html"

# Upload HTML files with shorter cache TTL
aws s3 sync ./website "s3://${BUCKET_NAME}" \
    --delete \
    --cache-control "public, max-age=0, must-revalidate" \
    --include "*.html"

echo "Sync completed successfully."

# 2. Invalidate CloudFront Cache
echo "[2/2] Creating CloudFront cache invalidation..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id "$DISTRIBUTION_ID" \
    --paths "/*" \
    --query "Invalidation.Id" \
    --output text)

echo "CloudFront Invalidation created with ID: $INVALIDATION_ID"
echo "Deployment completed successfully!"
