#!/bin/bash
# Write logs to /root/Provisioning.log
exec 3>&1 4>&2
exec 1> /root/Provisioning.log 2>&1
date

echo "Installing RPM for Provisioning Server"
yum install -y bind-utils
yum install -y gcc.x86_64
yum install -y gcc-c++.x86_64
yum install -y ksh.x86_64
yum install -y nmap
yum install -y ruby.x86_64
yum install -y ruby-devel.x86_64
yum install -y samba.x86_64
yum install -y samba-client.x86_64
yum install -y unzip.x86_64
yum install -y zip.x86_64
yum install -y zlib-devel.x86_64

echo "RPM's Install Successfully"
