#!/bin/bash

# Write logs to /tmp/customMetrics.log
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1> /tmp/customMetrics.log 2>&1
date

# OCI CLI binary location
# Default installation location for Oracle Linux 7 is /home/opc/bin/oci
cliLocation="/home/opc/bin/oci"

# Check if OCI CLI, jq, and curl is installed
if ! [ -x "$(command -v $cliLocation)" ]; then
  echo 'Error: OCI CLI is not installed. Please follow the instructions in this link: https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/cliinstall.htm' >&2
  exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed.' >&2
  exit 1
fi

metricNamespace="mycustomnamespace"
metricResourceGroup="mycustomnamespace_rg"

response=$(curl -s -L http://169.254.169.254/opc/v1/instance/ | jq '.id, .displayName, .compartmentId, .canonicalRegionName')
endpointRegion=$(curl -s -L http://169.254.169.254/opc/v1/instance/ | jq -r '.canonicalRegionName')
oracleOCIResponse=()
for x in $response
do
  oracleOCIResponse+=($x)
done

oracleTimestamp=$(date --rfc-3339=seconds | sed 's/ /T/')

oracleOciTemplate='{
"namespace":"%s",
"compartmentId":%s,
"resourceGroup":"%s",
"name":"diskUtilization",
"dimensions":{
  "resourceId":%s,
  "instanceName":%s,
  "MountPoint":"%s"
},
"metadata":{
  "unit":"Percent",
  "displayName":"Disc_Utilization"
},
"datapoints":[
  {
     "timestamp":"%s",
     "value":"%s"
  }
]}'

mountPoint=$(df -Ph | grep -vE '^Filesystem|tmpfs|cdrom' | column -t | awk '{print $6}' | grep -v Mounted)
oracleOCIResponseJSON='['
count=0
for mountName in $mountPoint
do
   diskUtilization=$(df -h $mountName | awk '{print $6,$5}' | tail -1 | awk '{print $2}' | tr -d '%')

   responseJSON=$(printf "$oracleOciTemplate" "$metricNamespace" "${oracleOCIResponse[2]}" "$metricResourceGroup" "${oracleOCIResponse[0]}" "${oracleOCIResponse[1]}" "$mountName" "$oracleTimestamp" "$diskUtilization")
   if [[ $count -gt 0 ]]
   then
     oracleOCIResponseJSON+=' , '
   fi
   ((count=count+1))
   oracleOCIResponseJSON+=$responseJSON
done
oracleOCIResponseJSON+=']'
echo $oracleOCIResponseJSON > /tmp/metrics.json


$cliLocation monitoring metric-data post --metric-data file:///tmp/metrics.json --endpoint https://telemetry-ingestion.$endpointRegion.oraclecloud.com

