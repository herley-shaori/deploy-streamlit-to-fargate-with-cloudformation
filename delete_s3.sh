#!/bin/bash

# Variables
OUTPUT_FILE="stack_name.txt"
REGION="ap-southeast-3"

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

# Empty the S3 bucket
echo "Emptying S3 bucket: $BUCKET_NAME"
aws s3 rm s3://$BUCKET_NAME --recursive --region $REGION

# Delete the CloudFormation stack
echo "Deleting CloudFormation stack: $STACK_NAME"
aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION

# Wait for the stack to be deleted
echo "Waiting for stack deletion to complete..."
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION

if [ $? -eq 0 ]; then
  echo "Stack $STACK_NAME deleted successfully."
  rm -f $OUTPUT_FILE
else
  echo "Failed to delete stack $STACK_NAME."
  exit 1
fi