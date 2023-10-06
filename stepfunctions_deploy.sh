#!/bin/bash
#
#
SM_LIST='statemachine.lst'
cat ${SM_LIST} | while read line
do
  SM_NAME=`echo "${line}" | awk -F',' {'print $1'}`
  SM_FILE=`echo "${line}" | awk -F',' {'print $2'}`
  echo "${SM_NAME} , ${SM_FILE}"
  cd stepfunctions
  pwd
  ls -l ${SM_FILE}"
  "aws stepfunctions update-state-machine --state-machine-arn ${SM_NAME} --definition file://${SM_FILE}"
  if [ $? -ne 0 ]; then
    echo "StepFunctions Deploy Error. StateMachineName=${SM_NAME}."
    exit 2
  fi
  cd ../
done