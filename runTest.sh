#!/bin/bash
GTAG=$(getCurrentGitTag.sh . | sed 's/.*-g//')
DS=$(date +%Y%m%d)
echo ./exacFilter.sh b37 Testing/test1.maf Testing/out1_${DS}_${GTAG}.maf
./exacFilter.sh b37 Testing/test1.maf Testing/out1_${DS}_${GTAG}.maf
