#!/bin/bash

echo "Installing RPM for Provisioning Server"
yum install -y bind-utils
yum install -y compat-libcap1.x86_64
yum install -y compatlibstdc++-33.x86_64
yum install -y gcc.x86_64
yum install -y gcc-c++.x86_64
yum install -y glibc.i686
yum install -y glibc.x86_64
yum install -y glibc-devel.x86_64
yum install -y ksh.x86_64
yum install -y libaio.x86_64
yum install -y libaio-devel.x86_64
yum install -y libgcc.x86_64
yum install -y libstdc++.x86_64
yum install -y libstdc++-devel.x86_64
yum install -y libX11.x86_64
yum install -y libXau.x86_64
yum install -y libxcb.x86_64
yum install -y libXext.x86_64
yum install -y libXi.x86_64
yum install -y libXtst.x86_64
yum install -y make.x86_64
yum install -y nmap
yum install -y sysstat.x86_64
yum install -y unzip.x86_64
yum install -y zip.x86_64

echo "RPM's Install Successfully"
