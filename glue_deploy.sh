#!/bin/bash
#
#
FUNC_LIST='lambda.lst'
cat ${FUNC_LIST} | while read line
do
  FUNC_NAME=`echo "${line}" | awk -F',' {'print $1'}`
  FUNC_FILE=`echo "${line}" | awk -F',' {'print $2'}`
  echo "${FUNC_NAME} , ${FUNC_FILE}"
  cd src/${FUNC_FILE}
  if [ $? -ne 0 ]; then
    echo "Lambda No such file or directory. FunctionName=${FUNC_NAME}, DirectoryName=${FUNC_FILE}."
    exit 2
  fi
  zip -r glue.zip ./*
  aws glue create-job --cli-input-json file://job1.json
  echo "$?"
  if [ $? -ne 0 ]; then
    echo "Lambda Deploy Error. FunctionName=${FUNC_NAME}."
    exit 2
  fi
  cd ../../
done
