cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bkp
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service sshd restart
