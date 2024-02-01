#!/bin/bash
#
#
SRC_REGION='ap-northeast-1'
DST_REGION='ap-northeast-3'
SRC_REPO='2175051-test-repo'
DST_REPO='2175051-test-dr-repo'
USERNAME='2175051_appOnly-at-477460359712'
PASS='c3BgNSqICOdcbP4oxO5p0EDhqTURSm8+w+4+CVFauyQ='

#################################################
###### src repo git pull & dst repo git push ####
#################################################
expect -c "
set timeout 10
spawn git clone https://git-codecommit.${DST_REGION}.amazonaws.com/v1/repos/${DST_REPO}
expect \"Username\"
send \"2175051_appOnly-at-477460359712\n\"
expect \"Password\"
send \"c3BgNSqICOdcbP4oxO5p0EDhqTURSm8+w+4+CVFauyQ=\n\"
interact
"
cd ./${DST_REPO}
git remote add torikomi_repo https://git-codecommit.${SRC_REGION}.amazonaws.com/v1/repos/${SRC_REPO}
expect -c "
set timeout 10
spawn git pull torikomi_repo main
expect \"Username\"
send \"2175051_appOnly-at-477460359712\n\"
expect \"Password\"
send \"c3BgNSqICOdcbP4oxO5p0EDhqTURSm8+w+4+CVFauyQ=\n\"
interact
"
git add .
git commit -m 'get source repo'
git remote rm torikomi_repo
git push origin main

