#!/bin/bash
#
#
BUCKET='s3://2175051-sf-cicd-test-bucket/glue/'
JOB_LIST='glue.lst'
cat ${JOB_LIST} | while read line
do
  JOB_NAME=`echo "${line}" | awk -F',' {'print $1'}`
  JOB_FILE=`echo "${line}" | awk -F',' {'print $2'}`
  echo "${JOB_NAME} , ${JOB_FILE}"
  cd ${JOB_NAME}/script
  if [ $? -ne 0 ]; then
    echo "Glue Job No such file or directory. JobName(Directory)=${JOB_NAME}, Job FileName=${JOB_FILE}."
    exit 2
  fi
  aws s3 cp ${JOB_FILE} s3://${BUCKET}${JOB_NAME}/
  if [ $? -ne 0 ]; then
    echo "Glue Job s3 Upload Error. JobName(Directory)=${JOB_NAME}, Job FileName=${JOB_FILE}."
    exit 2
  fi
  cd ../def
  aws glue update-job --cli-input-json file://definition.json
  if [ $? -ne 0 ]; then
    echo "Glue Job Deploy Error. JobName(Directory)=${JOB_NAME}, Job FileName=${JOB_FILE}."
    exit 2
  fi
  cd ../../
done
