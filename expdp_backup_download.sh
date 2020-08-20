#!/bin/bash
exec >/home/oracle/output.log 2>&1

DATE=`date -d '-1 day' +"%d_%b_%Y"`
#Exp_Dump_File=expdp_jdeprod_schema_backup_$DATE.tar.gz
Today_Dump_File=`oci os object list -bn 92Expdump --prefix expdp  |egrep -i "name|time-created" | awk '{print $2}' | awk -F, '{print $1}' | tr -d '"' |tail -2 | head -1`
Today_Dump_File_Size=`oci os object list -bn 92Expdump --prefix expdp  |egrep -i "name|time-created|size" | awk '{print $2}'|  awk -F, '{print $1}' | tr -d '"' | tail -3 | head -2 |tail -1`
DIR_File_count=`ls -l /backup/expdp_jdeprod | grep -w $Today_Dump_File | wc -l`
if [ $DIR_File_count -eq 1 ]
   then
     echo "Today's dump file $Today_Dump_File found"
         DIR_File_Size=`ls -lrt  /backup/expdp_jdeprod/$Today_Dump_File  | awk '{print $5}'`
         if [ "$Today_Dump_File_Size" -eq "$DIR_File_Size" ]
            then
                   echo "Today's dump file $Today_Dump_File found & size matched, exiting..."
                   exit 0;
            else
                rm -f /backup/expdp_jdeprod/$Today_Dump_File
                echo "file removed"
                cmd=`oci os object get -ns fr3qj9tyxw4e -bn 92Expdump --name $Today_Dump_File --file /backup/expdp_jdeprod/$Today_Dump_File`
           if [ $? = 0 ];
             then
               echo "download completed successfully"
             else
               echo "downlaod failed"
           fi
         fi
   elif [ $DIR_File_count -eq 0 ]
     then
           echo "Today's dump file $Today_Dump_File not found"
       echo "Run Below Command to get dump file"
       cmd=`oci os object get -ns fr3qj9tyxw4e -bn 92Expdump --name $Today_Dump_File --file /backup/expdp_jdeprod/$Today_Dump_File`
     if [ $? = 0 ];
       then
         echo "download completed successfully"
             exit 0
       else
         echo "downlaod failed"
         DIR_File_count1=`ls -l /backup/expdp_jdeprod | grep $Today_Dump_File | wc -l`
             if [ $DIR_File_count1 -eq 1 ]
           then
             echo "backup file is present on directory"
             rm -f /backup/expdp_jdeprod/$Today_Dump_File
             echo "file removed"
             cmd=`oci os object get -ns fr3qj9tyxw4e -bn 92Expdump --name $Today_Dump_File --file /backup/expdp_jdeprod/$Today_Dump_File`
             if [ $? = 0 ];
               then
                 echo "download completed successfully"
               else
                 echo "downlaod failed"
             fi
                 fi
         fi

fi
