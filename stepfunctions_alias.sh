#!/bin/bash
#
#
SM_LIST='statemachine.lst'
cat ${SM_LIST} | while read line
do
  SM_NAME=`echo "${line}" | awk -F',' {'print $1'}`
  SM_CURRENTVER=$(echo $(aws stepfunctions describe-state-machine-alias --state-machine-alias-arn ${SM_NAME}:prod | grep stateMachineVersionArn | tail -1 | cut -d : -f 9 | tr -cd 0-9))
  aws stepfunctions publish-state-machine-version --state-machine-arn ${SM_NAME} --description 'update version'
  if [ $? -ne 0 ]; then
    echo "StepFunctions Publish Version Error. StateMachineName=${SM_NAME}."
    exit 2
  fi
  SM_TARGETVER=$(echo $(aws stepfunctions list-state-machine-versions --state-machine-arn ${SM_NAME} | grep stateMachineVersionArn | head -1 | cut -d : -f 9 | tr -cd 0-9))
  echo "current ver.${SM_CURRENTVER} >> target ver.${SM_TARGETVER}"
  aws stepfunctions update-state-machine-alias --state-machine-alias-arn ${SM_NAME}:prod --routing-configuration stateMachineVersionArn=${SM_NAME}:${SM_TARGETVER},weight=100
  if [ $? -ne 0 ]; then
    echo "StepFunctions Alias Update Error. StateMachineName=${SM_NAME}."
    exit 2
  fi
done