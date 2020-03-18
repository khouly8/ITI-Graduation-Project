#!/bin/bash

yum -y install nfs-utils
systemctl enable nfs.service
systemctl restart nfs.service
firewall-cmd --add-service=nfs --permanent
firewall-cmd --add-service=mountd --permanent
firewall-cmd --add-service=rpc-bind  --permanent
firewall-cmd --reload

select option in add_share delete_share
do

	if [ $option ==  "add_share" ] 
	then
		echo "enter the ip of the server: "
		read ip 
		echo "what do you to name that share?  "
		read dir
		mkdir /mnt/$dir
		chmod o+w /mnt/$dir
		echo "/mnt/$dir  $ip(rw,no_root_squash)" >> /etc/exports
		exportfs -r
		
	fi
done
