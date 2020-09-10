#!/bin/bash
# echo "#####################################Don't change this script without CNC ADMIN Permission ##########################################"
# echo "#####################################This script use for application purpose. If you want to run this script run on UAT first #######"

current_ip=`grep -w PJDEESSVR /etc/hosts | awk '{ print $1 }'`
if [ $current_ip = "10.20.40.39" ]
  then
     echo quit | telnet 10.20.40.39 6017 | grep -q "Escape character is"
     if [ $? -eq 0 ]
         then
           echo "Port is reachable & host is primary"
           echo "Host change is not required"
         else
           echo "Port is not reachble, try one more time"
           sleep 50
           echo quit | telnet 10.20.40.39 6017 | grep -q "Escape character is"
           if [ $? -eq 0 ]
              then
                  echo "Port found up in 2nd attempt"
              else
                  cp /etc/hosts.b /etc/hosts
                  current_ip=`grep -w PJDEESSVR /etc/hosts | awk '{ print $1 }'`
                  if [ $current_ip = "10.20.40.31" ]
                  then
                    echo "Backup hots file copied sucessfully"
                  fi
           fi
      fi
   elif [ $current_ip = "10.20.40.31" ]
      then
         echo quit | telnet 10.20.40.39 6017 | grep -q "Escape character is"
         if [ $? -eq 0 ]
             then
                echo "Primary host is up now, copying primary host file"
                cp /etc/hosts.p /etc/hosts
                current_ip=`grep -w PJDEESSVR /etc/hosts | awk '{ print $1 }'`
                if [ $current_ip = "10.20.40.39" ]
                    then
                     echo "Primary hots file copied sucessfully"
                fi
       else
        echo "Primary host is stil not up"
    fi
 fi

