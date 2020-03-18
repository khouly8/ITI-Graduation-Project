#!/bin/bash

source Nginx.sh
source Web-Server.sh
source DNS.sh
source NFS.sh

#Coloring
Color_Off='\033[0m'       # Text Reset
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Cyan='\033[0;36m'         # Cyan


# Menu for the options
printf "Choose an option: \n 1-Web-Server\n 2-DNS\n 3-Load-Balancer\n 4-NFS\n"	       

# Read a choice from the user
read choice               

case $choice in
	#Connect remotly to the Web-Server and Run the Web-Server script
	1) 
        sshpass -p password ssh -o StrictHostKeyChecking=no -o CheckHostIP=no root@192.168.100.10 "bash /home/Web-Server.sh"
		;;			
	#Connect remotly to the DNS-server and Run the DNS script
	2)
		sshpass -p password ssh -o StrictHostKeyChecking=no -o CheckHostIP=no root@192.168.100.20 "bash /home/DNS.sh"
		;;
	#Connect remotly to the Load-Balancer and Run the Nginx script
	3)
		sshpass -p password ssh -o StrictHostKeyChecking=no -o CheckHostIP=no root@192.168.100.30 "bash /home/Nginx.sh"
		;;           			
	#Connect remotly to the NFS-Server and Run the NFS script
	4)
		sshpass -p password ssh -o StrictHostKeyChecking=no -o CheckHostIP=no root@192.168.100.40 "bash /home/NFS.sh"
		;;       			
	#if the user Entered unvalid number
	*)      
		printf "$Red \n Invalid choice $Color_Off"	 
		;;			
esac  