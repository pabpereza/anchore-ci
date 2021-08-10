#!/bin/bash

# Metadata
version="1.0.0"
last_updated="10 Aug, 2021"
mantainer="Pablo Perez-Aradros - x861459"

#Inputs
image=$1

#Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'


if [ -z "$image" ]; then
	echo -e "${RED}ERROR: ${NC}Image name not provided"
	echo -e "${YELLOW}INFO: ${NC}Usage: ./anchore-ci.sh <image_name>"
	exit 1
fi


echo -e "${GREEN}INFO: ${NC}Adding image to scan"
anchore-cli image add $image 1>/dev/null

echo -e "${GREEN}INFO: ${NC}Running scan and waiting for results"
anchore-cli image wait $image 1>/dev/null

echo -e "${GREEN}INFO: ${NC}Scan complete. Retrieving results"
results=$(anchore-cli image vuln $image all)
echo -e "\n ${GREEN}INFO: ${NC}Results:\n $results \n"

echo -e "${GREEN}INFO: ${NC}Evaluating with the polciies"
status=$(anchore-cli evaluate check $image | grep Status | awk '{print $2}')

if [ "$compliance" == "pass" ]; then
	echo -e "${GREEN}PASS: ${NC}Image $image is compliant"
	exit 0
else
	echo -e "${RED}ERROR: ${NC}Image $image is not compliant"
	exit 1
fi