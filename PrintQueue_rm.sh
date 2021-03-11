#!/bin/bash

echo "##################### Delete 180 Days Old PDF & CSV  file ###############"
cd /app/jdedwardsppack/e920/PrintQueue
current_path=`pwd`


if [ "$current_path" = "/app/jdedwardsppack/e920/PrintQueue" ];
   then
        echo "Run below command to take output and delete above 180 days file"
        find . -mtime +180 -name "*_PDF" > /tmp/print_queue_pdf.txt
        find . -mtime +180 -name "*.csv" > /tmp/print_queue_csv.txt
        find . -mtime +180 -name "*_PDF" -exec rm {} \;
        find . -mtime +180 -name "*.csv" -exec rm {} \;
    else
        echo "Current path is invalid"
fi
