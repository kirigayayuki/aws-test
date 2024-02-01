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
spawn git clone https://git-codecommit.ap-northeast-3.amazonaws.com/v1/repos/2175051-test-dr-repo
expect \"Username\"
send \"2175051_appOnly-at-477460359712\n\"
expect \"Password\"
send \"c3BgNSqICOdcbP4oxO5p0EDhqTURSm8+w+4+CVFauyQ=\n\"
interact
"
