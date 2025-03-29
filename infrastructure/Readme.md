# Terraform

## Preparation
1. Prepare access with
   ```console
   export AWS_PROFILE=dt
   ```
2. Deploy lambdas (for up-to-date "source_code_hash")

## Plan
Show the available changes
```console
cd infrastructure
terraform plan
```
## Apply
Deploy the changes to AWS
```console
cd infrastructure
terraform apply
```
