#!/bin/bash
#
#
FUNC_LIST='func.lst'
cat ${FUNC_LIST} | while read line
do
  FUNC_NAME=`echo "${line}" | awk -F',' {'print $1'}`
  FUNC_CURRENTVER=$(echo $(aws lambda get-alias --function-name ${FUNC_NAME} --name prod | grep FunctionVersion | tail -1 |tr -cd 0-9))
  aws lambda publish-version --function-name ${FUNC_NAME} --description "update version"
  FUNC_TARGETVER=$(echo $(aws lambda list-versions-by-function --function-name ${FUNC_NAME} | grep Version | tail -1 | tr -cd 0-9))
  echo "current ver.${FUNC_CURRENTVER} >> target ver.${FUNC_TARGETVER}"
  aws lambda update-alias --function-name ${FUNC_NAME} --name prod --function-version ${FUNC_TARGETVER}
  if [ $? -ne 0 ]; then
    echo "Lambda Deploy Error. FunctionName=${FUNC_NAME}."
    break
  fi
done
