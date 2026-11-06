# Static Website Hosting on AWS (S3, CloudFront, Route 53, IAM)

![AWS Architecture](https://img.shields.io/badge/AWS-S3%20%7C%20CloudFront%20%7C%20Route53%20%7C%20IAM-FF9900?logo=amazon-aws&logoColor=white)
![IaC](https://img.shields.io/badge/IaC-CloudFormation%20%7C%20Terraform-blue)
![License](https://img.shields.io/badge/License-MIT-green)

A production-ready cloud project demonstrating secure, highly available, and globally distributed static website hosting on Amazon Web Services using **Amazon S3**, **Amazon CloudFront**, **AWS Route 53**, and **AWS Identity and Access Management (IAM)**.

---

## Architecture Overview

```text
               +-----------------------+
               |     User Browser      |
               +-----------+-----------+
                           |
                     (HTTPS Request)
                           |
                           v
               +-----------+-----------+
               |    Amazon Route 53    |
               | (Custom Domain / DNS) |
               +-----------+-----------+
                           |
                           v
               +-----------+-----------+
               |   Amazon CloudFront   |
               |  (Global CDN / SSL)   |
               +-----------+-----------+
                           |
                 (Origin Access Control)
                  (Signed SigV4 Auth)
                           |
                           v
               +-----------+-----------+
               |    Amazon S3 Bucket   |
               |  (Private Asset Store)|
               +-----------------------+
```

### Traffic & Security Flow:
1. **DNS Resolution**: The user requests the domain; **Amazon Route 53** resolves the domain to CloudFront edge nodes using Alias (A/AAAA) records.
2. **Edge Acceleration & SSL Termination**: **Amazon CloudFront** caches content across global Points of Presence (PoPs) and terminates SSL/TLS with automated certificates from **AWS Certificate Manager (ACM)**.
3. **Origin Access Control (OAC)**: CloudFront signs requests using AWS **Signature Version 4 (SigV4)**.
4. **Zero Public S3 Access**: The **Amazon S3** bucket has all public access blocked. An IAM Bucket Policy allows read operations (`s3:GetObject`) strictly when `AWS:SourceArn` matches the specific CloudFront distribution ARN.

---

## Key Features & Security Controls

- **Origin Access Control (OAC)**: Implements the modern AWS security standard replacing legacy OAI.
- **S3 Block Public Access**: All 4 public access block flags are strictly enabled.
- **Automatic HTTPS Redirection**: Enforces TLS 1.2 / 1.3; all HTTP requests receive a `301 Moved Permanently` to HTTPS.
- **Custom Error Handling**: 404 and 403 HTTP errors seamlessly route to custom error pages (`/error.html` / SPA fallback).
- **Optimized Caching & Compression**: Automatic Gzip and Brotli compression with AWS Managed CachingOptimized policy.
- **Dual Infrastructure as Code (IaC)**: Deployable via **AWS CloudFormation** or **HashiCorp Terraform**.
- **Automated CI/CD Deployment**: CLI and Python (Boto3) scripts to sync assets and trigger automatic cache invalidations.

---

## Repository Structure

```text
aws-static-website-hosting/
│
├── website/
│   ├── index.html            # Responsive cloud portfolio landing page
│   ├── styles.css            # Modern CSS with dark/light mode
│   ├── script.js             # Interactive client-side JavaScript
│   └── error.html            # Custom 404 error page
│
├── infrastructure/
│   ├── cloudformation.yaml   # AWS CloudFormation template
│   └── terraform/            # HashiCorp Terraform configuration
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── scripts/
│   ├── deploy.sh             # Bash automated sync & invalidation script
│   └── deploy.py             # Python (Boto3) cross-platform deployer
│
└── README.md
```

---

## Deployment Instructions

### Option A: Deploy via AWS CloudFormation (AWS CLI)

1. **Deploy Infrastructure**:
   ```bash
   aws cloudformation deploy \
     --template-file infrastructure/cloudformation.yaml \
     --stack-name static-website-production \
     --parameter-overrides ProjectName=my-cloud-portfolio Environment=production \
     --capabilities CAPABILITY_IAM
   ```

2. **Retrieve Stack Outputs**:
   ```bash
   aws cloudformation describe-stacks \
     --stack-name static-website-production \
     --query "Stacks[0].Outputs" \
     --output table
   ```

3. **Upload Website Files & Invalidate CDN**:
   ```bash
   BUCKET_NAME=$(aws cloudformation describe-stacks --stack-name static-website-production --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" --output text)
   DIST_ID=$(aws cloudformation describe-stacks --stack-name static-website-production --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDistributionId'].OutputValue" --output text)

   chmod +x ./scripts/deploy.sh
   ./scripts/deploy.sh "$BUCKET_NAME" "$DIST_ID"
   ```

---

### Option B: Deploy via Terraform

1. **Initialize & Apply**:
   ```bash
   cd infrastructure/terraform
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

2. **Sync Website Assets**:
   ```bash
   BUCKET=$(terraform output -raw s3_bucket_name)
   DIST_ID=$(terraform output -raw cloudfront_distribution_id)
   
   cd ../..
   python ./scripts/deploy.py "$BUCKET" "$DIST_ID"
   ```

---

## Verification & Testing

1. **Verify HTTPS Redirection**:
   ```bash
   curl -I http://YOUR_CLOUDFRONT_DOMAIN
   # Expected HTTP status: 301 Moved Permanently
   # Location: https://YOUR_CLOUDFRONT_DOMAIN/
   ```

2. **Verify Public S3 Access is Blocked**:
   ```bash
   curl -I https://YOUR_BUCKET.s3.amazonaws.com/index.html
   # Expected HTTP status: 403 Forbidden
   ```

3. **Verify CloudFront Caching**:
   ```bash
   curl -I https://YOUR_CLOUDFRONT_DOMAIN/index.html
   # Look for headers:
   # X-Cache: Hit from cloudfront (or Miss on first request)
   ```

---

## Author

**Kasanaboina Kowshik**  
- **Role:** Aspiring AWS Cloud Engineer  
- **GitHub:** [@kowshik-8790](https://github.com/kowshik-8790)  
- **LinkedIn:** [linkedin.com/in/kasanaboina-kowshik](https://linkedin.com/in/kasanaboina-kowshik)  
- **Email:** kasanaboinakowshik@gmail.com
