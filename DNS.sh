#!/bin/bash

yum -y install bind bind-utils &> /dev/null
firewall-cmd --permanent --add-service=dns &> /dev/null
firewall-cmd --permanent --add-port=53/udp &> /dev/null
firewall-cmd --reload &> /dev/null
rm /etc/named.conf
touch /etc/named.conf
echo '//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//
// See the BIND Administrators Reference Manual (ARM) for details about the
// configuration located in /usr/share/doc/bind-{version}/Bv9ARM.html

options {
        listen-on port 53 { any; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        recursing-file  "/var/named/data/named.recursing";
        secroots-file   "/var/named/data/named.secroots";
        allow-query     {192.168.80.1;192.168.80.2;localhost; };

        /*
         - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
         - If you are building a RECURSIVE (caching) DNS server, you need to enable
           recursion.
         - If your recursive DNS server has a public IP address, you MUST enable access
           control to limit queries to your legitimate users. Failing to do so will
           cause your server to become part of large scale DNS amplification
           attacks. Implementing BCP38 within your network would greatly
           reduce such attack surface
        */
        recursion yes;

        dnssec-enable yes;
        dnssec-validation yes;

        /* Path to ISC DLV key */
        bindkeys-file "/etc/named.root.key";

        managed-keys-directory "/var/named/dynamic";

        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
        type hint;
        file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
' >> /etc/named.conf


PS3='Please enter your choice: '
options=("Add Domain" "Delete Domain" "List Domains" "Quit")
select opt in "${options[@]}"

do
    case $opt in
        "Add Domain")
            echo "you chose Add Domain"
echo "Enter number of Domains"
read number

for i in $(seq 1 $number)
do

echo "Enter Domain"
read domain


echo "Enter IP"
read ip


if grep -Fxq "#$domain" /etc/named.rfc1912.zones
then
echo "Domain already Exists"
else

echo "$domain" >> DNS.txt
echo "$ip" >> DNS.txt

echo "
#$domain
zone \"$domain\" IN {
        type master;
        file \"$domain\";
        allow-update { none; };
};" >> /etc/named.rfc1912.zones

echo "\$TTL 3H
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
        A       127.0.0.1
        AAAA    ::1
www     IN  A   $ip
" > /var/named/$domain
chgrp named /var/named/$domain
fi
done
  ;;
        "Delete Domain")
            echo "you choose to Delete a Domain"

echo "Enter Domain name"
read domain


sed -e "/#$domain/,+5d" /etc/named.rfc1912.zones  >> /etc/named.rfc1912_2.zones
mv /etc/named.rfc1912_2.zones /etc/named.rfc1912.zones

rm /var/named/$domain  2> /dev/null




sed -e "/$domain/,+1d" DNS.txt  >> DNS2.txt
mv DNS2.txt DNS.txt




            ;;
        "List Domains")
            echo "you chose choice $REPLY which is $opt"
cat DNS.txt
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

systemctl restart named
