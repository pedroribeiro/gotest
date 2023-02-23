#!/bin/sh

API_NAME=gotest
REGION=us-east-1
STAGE=test

LAMBDA_ARN=$(awslocal lambda list-functions --query "Functions[?FunctionName==\`${API_NAME}\`].FunctionArn" --output text --region ${REGION})

echo $LAMBDA_ARN

awslocal apigateway create-rest-api \
    --region ${REGION} \
    --name ${API_NAME}

API_ID=$(awslocal apigateway get-rest-apis --query "items[?name==\`${API_NAME}\`].id" --output text --region ${REGION})
PARENT_RESOURCE_ID=$(awslocal apigateway get-resources --rest-api-id ${API_ID} --query 'items[?path==`/`].id' --output text --region ${REGION})

awslocal apigateway create-resource \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --parent-id ${PARENT_RESOURCE_ID} \
    --path-part "{app}"

RESOURCE_ID=$(awslocal apigateway get-resources --rest-api-id ${API_ID} --query 'items[?path==`/{app}`].id' --output text --region ${REGION})

awslocal apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method GET \
    --request-parameters "method.request.path.app=true" \
    --authorization-type "NONE" \

awslocal apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN}/invocations \
    --passthrough-behavior WHEN_NO_MATCH \

awslocal apigateway create-deployment \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --stage-name ${STAGE} \

ENDPOINT=http://localhost:4566/restapis/${API_ID}/${STAGE}/_user_request_/HowMuchIsTheFish

echo "API available at: ${ENDPOINT}"
