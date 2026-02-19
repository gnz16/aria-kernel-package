---
description: Deploy application to AWS with infrastructure as code
---

1. **Containerize application**
   - Ensure a robust `Dockerfile` and `docker-compose.yml` are present for consistent deployment.

2. **Set up IAM roles and policies**
   - Configure necessary AWS permissions for the application and deployment tools.

3. **Create infrastructure template**
   - Define the AWS resources (compute, networking, etc.) using CloudFormation or similar IaC.

4. **Configure S3 buckets** (Optional)
   - Set up static asset hosting or data storage buckets.

5. **Deploy Lambda functions** (Optional)
   - Deploy serverless components if the application architecture requires them.

6. **Deploy to Kubernetes (EKS)** (Optional)
   - Orchestrate the deployment if using container clusters.
