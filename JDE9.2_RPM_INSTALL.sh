#!/bin/bash
exec 3>&1 4>&2 > rpm_output 2>&1

A=JDE9.2_RPM

cat $A | while read line
do
    tag=$(echo "${line}"|awk -F'=' '{print $1}')
    value=$(echo "${line}"|awk -F'=' '{print $2}')
    if [[ "${tag}" = "packagelist" ]]; then
            for pkg in $(echo "${value}" | sed "s/,/ /g")
            do

                    sudo yum install -y "${pkg}" && sleep 5
            done
    fi
done
