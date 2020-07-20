#!/bin/bash
DATE=`date -d '-1 day' +"%d_%b_%Y"`
Exp_Dump_File=expdp_jdeprod_schema_backup_$DATE.tar.gz
Today_Dump_File=`oci os object list -bn 92Expdump --prefix expdp  |egrep -i "name|time-created" | awk '{print $2}' | awk -F, '{print $1}' | tr -d '"'|tail -2 | head -1`
if [ $Exp_Dump_File = $Today_Dump_File ];
then
     echo "File is present. Copy data from object to localdrive"
     oci os object get -ns fr3qj9tyxw4e -bn 92Expdump --name $Today_Dump_File --file /backup/onprembkp_03062020/JDENONPD_PDB1/$Today_Dump_File
else
     echo "File is absent"
fi
