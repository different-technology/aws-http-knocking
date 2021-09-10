#!/bin/bash

# Call:
# cd /lambda/Firewall
# export AWS_PROFILE=dt

scripts/build.sh
echo 'Upload to AWS'
aws lambda update-function-code --region eu-central-1 --function-name OpenFirewall --zip-file fileb://build/build.zip
aws lambda update-function-code --region eu-central-1 --function-name CleanupFirewall --zip-file fileb://build/build.zip
