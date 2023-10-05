#!/bin/bash
#
#
FUNC_LIST='func.lst'
cat ${FUNC_LIST} | while read line
do
  FUNC_NAME=`echo "${line}" | awk -F',' {'print $1'}`
  FUNC_FILE=`echo "${line}" | awk -F',' {'print $2'}`
  echo "${FUNC_NAME} , ${FUNC_FILE}"
  cd lambda/${FUNC_FILE}
  zip -r lambda.zip ./*
  aws lambda update-function-code --function-name ${FUNC_NAME} --zip-file fileb://lambda.zip
  if [$? ne 0]; then
    echo "Lambda Deploy Error. FunctionName=${FUNC_NAME}."
    exit 255
  fi
  cd ../../
done
