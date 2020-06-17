#!/bin/bash
host="$(hostname)"
printf "server name is %s\n" "$host"
date="$(date)"
printf "Current date and time %s\n" "$date"
ip="$(ip r |grep -i "link src" | awk '{print $9}')"
printf "Server IP Address is %s\n" "$ip"

echo  ############################## "Set Root and OPC password" #################################################
	echo "Dr@v!d_11@India" | passwd --stdin opc
	echo "S@ch1n_10@India" | passwd --stdin root

echo  ##############################"Change Below parameter in SSHD_CONFIG file" #################################

current_version=`grep 7 /etc/redhat-release | awk  '{print $7 }' | awk -F. '{print $1}'`
if [ $current_version = "7" ]
   then
   echo "Run Below Command to change AddressFamily and  PasswordAuthentication parameter on ssh/sshd_config file"
   cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bkp
   sed -i 's/#AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config
   sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
   service sshd restart
   else
   echo "Run Below Command to change only PasswordAuthentication parameter on ssh/sshd_config file"
   cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bkp
   sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
   service sshd restart
 fi


echo #############################"Change PRESERVE_HOSTINFO parameter value in  /etc/oci-hostname file"#####################


current_value=`grep =0 /etc/oci-hostname.conf | head -n2  | sed -e 's/^.\{18\}//'`
if [ $current_value = "0" ];
 then
 echo "Run Below Command to change PRESERVE_HOSTINFO value on /etc/oci-hostname file"
 cp /etc/oci-hostname.conf /etc/oci-hostname.conf.bkp
 sed -i 's/PRESERVE_HOSTINFO=0*/PRESERVE_HOSTINFO=3/' /etc/oci-hostname.conf
else
    echo "Already done"
fi


echo #################################"User id creation on Linux server"###############################################\

A=cncadmin
B=oracle
C=tiscoadmin

if [ $(id -u) -eq 0 ]; then
        egrep "^$A" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                echo "$username exists!"
                exit 1
        else
                useradd -m cncadmin
                echo "Tisco@123456" | passwd --stdin cncadmin
                cp /etc/sudoers /etc/sudoers.bkp
                echo    "cncadmin    ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
                useradd -m oracle
                echo "IDfc$#6yhnNHY^" | passwd --stdin oracle
                useradd -m tiscoadmin
                echo "H0r!zon!@2020" | passwd --stdin tiscoadmin
                echo "tiscoadmin    ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers

                [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
        fi
else
        echo "Only root may add a user to the system."
        exit 2
fi


echo ####################################"Disabled SELINUX in /etc/selinux/config file" ###############################

current_status=`grep SELINUX=enforcing /etc/selinux/config`

if [ $current_status = "SELINUX=enforcing" ];
then
	echo "Run Below Command to change  SELINUX=disableed value on /etc/selinux/config file"
    cp /etc/selinux/config /etc/selinux/config.bkp
    sed -i 's/SELINUX=enforcing*/SELINUX=disabled/' /etc/selinux/config
else 
	"SELINUX already in disabled mode"
fi
|

echo #################################"Change Timezone setting on server" ################################################

current_version=`grep 7 /etc/redhat-release | awk  '{print $7 }' | awk -F. '{print $1}'`
if [ "$current_version" -eq "7" ];
   then
           echo "Run below command to change timezone in OEL 7"
           timedatectl list-timezones | grep -i MUS
           timedatectl set-timezone Asia/Muscat
           systemctl restart systemd-timedated

elif [ "$current_version" -le "7" ];
     then
           echo "OS version is  OEL 6. Run below command to change timezone"
           cp /etc/localtime /etc/localtime.bkp
           rm -fr /etc/localtime
           ln -s /usr/share/zoneinfo/Asia/Muscat /etc/localtime
fi
