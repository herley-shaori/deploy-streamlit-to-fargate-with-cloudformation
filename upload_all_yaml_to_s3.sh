#!/bin/bash

# Variables
OUTPUT_FILE="stack_name.txt"
REGION="ap-southeast-3"
S3_FOLDER="cfn"

# Check if the stack_name.txt file exists
if [ ! -f $OUTPUT_FILE ]; then
  echo "Error: $OUTPUT_FILE not found."
  exit 1
fi

# Read the stack name from the file
STACK_NAME=$(cat $OUTPUT_FILE)

# Get the bucket name from the CloudFormation stack
BUCKET_NAME=$(aws cloudformation describe-stack-resource --stack-name $STACK_NAME --logical-resource-id S3Bucket --query 'StackResourceDetail.PhysicalResourceId' --output text --region $REGION)

# Check if the bucket name was retrieved
if [ -z "$BUCKET_NAME" ]; then
  echo "Error: Unable to retrieve the bucket name from the stack $STACK_NAME."
  exit 1
fi

# Upload all .yaml files in the current directory to the S3 bucket under the cfn folder, except .venv folder
for FILE in *.yaml; do
  if [ -f "$FILE" ] && [ "$FILE" != ".venv" ]; then
    aws s3 cp $FILE s3://$BUCKET_NAME/$S3_FOLDER/$FILE --region $REGION
    if [ $? -eq 0 ]; then
      echo "Successfully uploaded $FILE to s3://$BUCKET_NAME/$S3_FOLDER/"
    else
      echo "Failed to upload $FILE."
      exit 1
    fi
  fi
done