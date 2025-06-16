#!/bin/bash

# === CONFIGURATION ===
STACK_NAME="softether-vpn-stack-1"
TEMPLATE_FILE="Softether-VPN-CF-Temp.yaml"

# === PARAMETERS ===
INSTANCE_NAME="SoftEther-EC2"
INSTANCE_TYPE="t3.micro"
KEY_NAME="softether-vpn-stack"
VPC_ID="vpc-04442e8729897e2c0"
SUBNET_ID="subnet-08c418d9ea383789f"
ATTACH_SSM_ROLE="true"
ENVIRONMENT="dev"
CREATED_BY="Futuralis"
PROJECT_NAME="SoftEtherVPN"

# === AMI RESOLUTION ===
echo "🔍 Resolving latest Amazon Linux 2 AMI..."
REGION=$(aws configure get region)
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-2.0.*-x86_64-gp2" \
  "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].ImageId" \
  --output text --region $REGION)

if [ -z "$AMI_ID" ]; then
  echo "❌ ERROR: Failed to find Amazon Linux 2 AMI"
  exit 1
fi
echo "✅ Using AMI: $AMI_ID"

# === STACK DEPLOYMENT ===
echo "🚀 Deploying CloudFormation stack: $STACK_NAME"
aws cloudformation deploy \
  --template-file "$TEMPLATE_FILE" \
  --stack-name "$STACK_NAME" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    "InstanceName=$INSTANCE_NAME" \
    "InstanceType=$INSTANCE_TYPE" \
    "KeyName=$KEY_NAME" \
    "LatestAmiId=$AMI_ID" \
    "VpcId=$VPC_ID" \
    "SubnetId=$SUBNET_ID" \
    "AttachSSMRole=$ATTACH_SSM_ROLE" \
    "Environment=$ENVIRONMENT" \
    "CreatedBy=$CREATED_BY" \
    "ProjectName=$PROJECT_NAME" \
  --no-fail-on-empty-changeset

# === WAIT FOR COMPLETION ===
echo "⏳ Waiting for stack creation..."
aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME"

# === OUTPUT RESULTS ===
if [ $? -eq 0 ]; then
  echo "✅ Stack created successfully!"
  echo "📋 Stack outputs:"
  aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --query "Stacks[0].Outputs" \
    --output table
else
  echo "❌ Stack creation failed!"
  echo "🔍 Checking for errors..."
  
  # Check if stack exists first
  if aws cloudformation describe-stacks --stack-name "$STACK_NAME" &>/dev/null; then
    echo "Last 5 error events:"
    aws cloudformation describe-stack-events \
      --stack-name "$STACK_NAME" \
      --query "StackEvents[?ResourceStatus=='CREATE_FAILED'] | [0:5].[LogicalResourceId, ResourceStatusReason]" \
      --output table
  else
    echo "Stack creation failed before any resources were created."
    echo "Common causes:"
    echo "1. Invalid parameter values"
    echo "2. Insufficient IAM permissions"
    echo "3. Template validation errors"
  fi
  
  exit 1
fi