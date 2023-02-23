#!/bin/bash

awslocal lambda create-function --function-name gotest --runtime go1.x --handler main --zip-file fileb:///root/init/arc.zip --role arn:aws:iam::0000000000:role/LambdaFullAccess

echo "All resources initialized! 🚀"
