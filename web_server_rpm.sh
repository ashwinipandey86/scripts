#!/bin/bash
# Write logs to /root/weblogic.log
exec 3>&1 4>&2
exec 1> /root/weblogic.log 2>&1
date
echo "Installing RPM for Provisioning Server"
yum install -y bind-utils
yum install -y glibc.i686
yum install -y glibc.x86_64
yum install -y glibcdevel.x86_64
yum install -y ksh.x86_64
yum install -y net-tools
yum install -y nmap
yum install -y unzip.x86_64
yum install -y zip.x86_64
yum install -y zlibdevel.x86_64

echo "RPM's Install Successfully"
