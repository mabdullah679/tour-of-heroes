#!/bin/bash
INSTANCE_ID=$1
REGION=$2
aws ec2 stop-instances --instance-ids $INSTANCE_ID --region $REGION

