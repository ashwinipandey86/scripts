#!/bin/bash
# Write logs to /root/configured.log
exec 3>&1 4>&2
exec 1> /root/configured.log 2>&1
date

echo  ############################## "Set Root and OPC password" #################################################
	echo "Birla@123456" | passwd --stdin opc
	echo "B!rL@M1R@_JDE2020" | passwd --stdin root


echo "############################Creation of LVM Mount Point######################################"

echo -e ” \nScan and Detect newly connected SCSI LUN”
host=`ls -l /sys/class/scsi_host/ | grep -v total | awk '{print $9}' | awk -F "h                                                                             ost" '{print $2}'`
for i in $host
do
echo “Rescaning scsi host /sys/class/scsi_host/host”
echo "- - -" > /sys/class/scsi_host/host$i/scan
done
echo -e “\n All the SCSI LUN scanned Sucessfully…..”


D=$(fdisk -l | grep -i /dev/sd | awk {'print $2}' | cut -d ":" -f1 | wc -l)
if [ $D -gt 1 ];
then
   echo "Run Below command to create filesystem"
BV=$(fdisk -l | grep -i /dev/sd | tail -1 | awk {'print $2}' | cut -d ":" -f1)
V=u01vg
L=u01lv
A=/u01
pvcreate $BV
vgcreate $V $BV
S=$(vgdisplay $V | grep Total | perl -pe 's/[^0-9]+//g')
lvcreate -l $S $V -n $L
mke2fs -t ext4 /dev/$V/$L
tune2fs -m 0 /dev/$V/$L
mkdir $A
mount /dev/$V/$L $A
chmod 770 $A
echo -e "/dev/$V/$L\t\t$A\t\text4\tdefaults,noatime,_netdev\t\t0 0" >> /etc/fstab
else
     echo "diks not found"
fi


echo  "############################## Change Below parameter in SSHD_CONFIG file ##################################"

current_version=`grep 7 /etc/redhat-release | awk  '{print $7 }' | awk -F. '{print $1}'`
if [ $current_version = "7" ]
   then
   echo "Run Below Command to change AddressFamily and  PasswordAuthentication parameter on ssh/sshd_config file"
   cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bkp
   sed -i 's/#AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config
   sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
   sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 3600/' /etc/ssh/sshd_config
   service sshd restart
   else
   echo "Run Below Command to change only PasswordAuthentication parameter on ssh/sshd_config file"
   cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bkp
   sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
   service sshd restart
 fi


echo "############################# Change PRESERVE_HOSTINFO parameter value in  /etc/oci-hostname file #####################"


current_value=`grep =0 /etc/oci-hostname.conf | head -n2  | sed -e 's/^.\{18\}//'`
if [ $current_value = "0" ];
 then
 echo "Run Below Command to change PRESERVE_HOSTINFO value on /etc/oci-hostname file"
 cp /etc/oci-hostname.conf /etc/oci-hostname.conf.bkp
 sed -i 's/PRESERVE_HOSTINFO=0*/PRESERVE_HOSTINFO=3/' /etc/oci-hostname.conf
else
    echo "Already done"
fi

echo "#################################### Disabled SELINUX in /etc/selinux/config file ###############################"

current_status=`grep SELINUX=enforcing /etc/selinux/config`

if [ $current_status = "SELINUX=enforcing" ];
then
	echo "Run Below Command to change  SELINUX=disableed value on /etc/selinux/config file"
    cp /etc/selinux/config /etc/selinux/config.bkp
    sed -i 's/SELINUX=enforcing*/SELINUX=disabled/' /etc/selinux/config
else 
	"SELINUX already in disabled mode"
fi


echo "################################### Disable IPV6 in /etc/sysctl.conf file ########################################"

cp /etc/sysctl.conf /etc/sysctl.conf.bkp
current_value=`grep "net.ipv6.conf.default.disable_ipv6 = 1" /etc/sysctl.conf`

if [ "$current_value" = "net.ipv6.conf.default.disable_ipv6 = 1" ]
then
    echo "net.ipv6.conf.default.disable_ipv6 perameter is alredy added"
else
    echo "Add net.ipv6.conf.default.disable_ipv6 = 1 and net.ipv6.conf.all.disable_ipv6 = 1 in /etc/sysctl.com file"
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.disable_ipv6 = 1 " >> /etc/sysctl.conf
    sysctl -p
fi

echo "###################################### Stop Firewall on system ######################################"

current_value=`systemctl status firewalld | grep -i Active | awk '{print $3}'`

if [ $current_value = "(running)" ]
then
     echo "Firewall is running. Stop the iptables"
     iptables -L
     iptables -F
     systemctl stop firewalld
else
     echo "Firewall is Already Stopped"
fi

echo #################################"User id creation on Linux server"###############################################\

A=jdeadmin
B=oracle
C=dba

if [ $(id -u) -eq 0 ]; then
        egrep "^$A" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                echo "$username exists!"
                exit 1
        else
                useradd -m jdeadmin
                echo "XfYbR2kfg@" | passwd --stdin jdeadmin
                cp /etc/sudoers /etc/sudoers.bkp
                echo    "jdeadmin    ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
                useradd -m oracle
                echo "Birla#1234" | passwd --stdin oracle
                groupadd dba
                usermod -g oracle opc
				usermod -a -G dba oracle
                chgrp oracle /u01
                echo "opc    ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers

                [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
        fi
else
        echo "Only root may add a user to the system."
        exit 2
fi

echo "################################X11-Pkg and Telnet RPMs installation ###################################"

current_value=`rpm -qa |grep -i xorg-x11-xauth | wc -l`

if [ "$current_value" = "0" ];
then
   echo "Xorg-x11-xauth rpm is not installed. install pkg now"
   yum install xorg-x11-xauth.x86_64 xorg-x11-server-utils.x86_64 dbus-x11.x86_64 xclock* telnet* -y
   echo "xorg-x11-xauth rpm is installed successfully"
else
   echo "Xorg-x11-xauth rpm is already installed"
fi

