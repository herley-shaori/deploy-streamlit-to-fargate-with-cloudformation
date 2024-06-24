#!/bin/bash

# Variables
TEMPLATE_FILE="s3.yaml"
STACK_NAME="my-s3-bucket-stack-asdnkasdaknscasc"
BUCKET_NAME="nested-cloudformation-sdks833njk33k"
REGION="ap-southeast-3"
OUTPUT_FILE="stack_name.txt"

# Deploy CloudFormation stack
aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://$TEMPLATE_FILE --parameters ParameterKey=BucketName,ParameterValue=$BUCKET_NAME --region $REGION

# Check if the stack creation was successful
if [ $? -eq 0 ]; then
  echo "Stack $STACK_NAME created successfully."
  echo $STACK_NAME > $OUTPUT_FILE
else
  echo "Failed to create stack $STACK_NAME."
  exit 1
fi