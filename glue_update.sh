#!/bin/bash
#
#
#BUCKET='2175051-sf-cicd-test-bucket/glue/'
JOB_PREFIX='source/'
LIB_PREFIX='lib/'
JOB_LIST='glue_job.lst'
LIB_LIST='glue_lib.lst'

#################################################
###### job library list load & file update ######
#################################################
cat ${LIB_LIST} | while read line
do
  LIB_FILE=`echo "${line}" | awk -F',' {'print $1'}`
  echo "Start checking  SourceFilePass=${LIB_FILE}."
  ls ${LIB_FILE}
  if [ $? -ne 0 ]; then
    echo "Glue Job Library File No such file or directory. SourceFilePass=${LIB_FILE}."
    exit 2
  fi
  aws s3 cp ${LIB_FILE} s3://${BUCKET}${LIB_PREFIX}
  if [ $? -ne 0 ]; then
    echo "Glue Job Library File s3 Upload Error. SourceFilePass=${LIB_FILE}."
    exit 2
  fi
done
#################################################
###### job list load & file update & deploy #####
#################################################
cat ${JOB_LIST} | while read line
do
  JOB_NAME=`echo "${line}" | awk -F',' {'print $1'}`
  JOB_DIR=`echo "${line}" | awk -F',' {'print $2'}`
  JOB_FILE=`echo "${line}" | awk -F',' {'print $3'}`
  echo "Start checking GlueJobName=${JOB_NAME}, SourceFilePass=${JOB_DIR}${JOB_FILE}."
  ls ${JOB_DIR}${JOB_FILE}
  if [ $? -ne 0 ]; then
    echo "Glue Job Script File No such file or directory. SourceFilePass=${JOB_DIR}${JOB_FILE}."
    exit 2
  fi
  echo "Start deploying ${JOB_NAME}."  
  aws s3 cp ${JOB_DIR}${JOB_FILE} s3://${BUCKET}${JOB_PREFIX}
  if [ $? -ne 0 ]; then
    echo "Glue Job Script File s3 Upload Error. SourceFilePass=${JOB_DIR}${JOB_FILE}."
    exit 2
  fi
  aws glue update-job --cli-input-json file://${JOB_DIR}definition.json
  if [ $? -ne 0 ]; then
    echo "Glue Job Deploy Error. GlueJobName=${JOB_NAME}, SourceFilePass=${JOB_DIR}${JOB_FILE}."
    exit 2
  fi
done
