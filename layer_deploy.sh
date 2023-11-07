#!/bin/bash
#
#
AWS_ACCOUNT='477460359712'
LAYER_NAME='2175051-psycopg2'
LAYER_SRCDIR='src'
RUNTIME='python3.10'
FUNC_LIST='lambda.lst'
  ### file check ###
  echo "Start checking LayerName=${LAYER_NAME}, SourceDirectoryPass=${LAYER_SRCDIR}."
  cd ${LAYER_SRCDIR}
  if [ $? -ne 0 ]; then
    echo "Layer No such file or directory. LayerName=${LAYER_NAME}, SourceDirectoryName=${LAYER_SRCDIR}."
    exit 2
  fi
  ### layer deploy ###
  echo "Start deploying ${LAYER_NAME}."
  zip -r layer.zip ./*
  aws lambda publish-layer-version \
  --layer-name ${LAYER_NAME} \
  --description "update version" \
  --zip-file fileb://layer.zip \
  --compatible-runtimes ${RUNTIME}
  echo "$?"
  if [ $? -ne 0 ]; then
    echo "Layer Deploy Error. LayerName=${LAYER_NAME}, SourceDirectoryName=${LAYER_SRCDIR}."
    exit 2
  fi
  cd ../
  ### layer version function association update ###
  LAYER_TARGETVER=$(echo $(aws lambda list-layer-versions --layer-name ${LAYER_NAME} | jq -r '.LayerVersions | .[] | .Version' | head -1))
cat ${FUNC_LIST} | while read line
do
  FUNC_NAME=`echo "${line}" | awk -F',' {'print $1'}`
  LAYER_CURRENTVER=$(echo $(aws lambda get-function --function-name ${FUNC_NAME} | jq -r '.Configuration | .Layers | .[] | .Arn' | grep ${LAYER_NAME} | head -1 | awk -F'[:]' '{print $8}'))
  echo "Start updating ${FUNC_NAME}'s version from CurrentVer.${LAYER_CURRENTVER} to TargetVer.${LAYER_TARGETVER}."
  aws lambda update-function-configuration \
  --function-name ${FUNC_NAME} \
  --layers arn:aws:lambda:ap-northeast-1:${AWS_ACCOUNT}:layer:${LAYER_NAME}:${LAYER_TARGETVER}
  if [ $? -ne 0 ]; then
    echo "Lambda Layer Version Update Error. FunctionName=${FUNC_NAME}, LayerName=${LAYER_NAME}, LayerVersion=${LAYER_TARGETVER}."
    exit 2
  fi
done
