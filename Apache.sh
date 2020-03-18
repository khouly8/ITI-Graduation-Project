
function DomainName
{
        while [ -z $DName ]
                do
                echo "Enter Domain Name"
                read DName
                DName=$(echo $DName| awk '{print tolower($0)}')
                done
}


function CreateDomain
{
        #That function is used to create virtual host, by creating virtual host configration at /etc/httpd/conf.d
        #and domain directory at /var/www, it also creates index.html inside domain directory that contain domain name and host ip,
        #and creates .htaccess file that have the domaoin options.it return 1 if it couldn't create th domain.

        FLAG=1                                  #couldn't create the domain return code

        source ./00-domainname.sh
        DomainName                              #read domain name from admin

        if [ ! -d /var/www/"$DName" ]  #check if domain is already exists or not
                then
                mkdir /var/www/"$DName"         #1-create domain diretory

                echo "DomainName= $DName, MachineName= $(hostnamectl --pretty status)" > /var/www/"$DName"/index.html   #2-create domain index.html

                echo "DirectoryIndex index.html
                  Require all granted" >> /var/www/"$DName"/.htaccess           #3-create .htaccess file

                echo "<virtualHost *:80>
                        serverName $DName
                        ServerAlias WWW.$DName
                        DocumentRoot /var/www/$DName
                        ErrorLog /var/log/httpd/$DName.error.log
                        CustomLog /var/log/httpd/$DName.access.log common
                </VirtualHost>" > /etc/httpd/conf.d/virtualhost/"$DName".conf   #4-create virtual host configration

                systemctl restart httpd                                                 #5-restart the serviec
                FLAG=0                                                                  #6-change reurn code
        fi
        return $FLAG
}

function DeleteDomain
{
        FLAG=2
        source ./00-domainname.sh
        DomainName

        if [ -d /var/www/"$DName" ]
                then
                rm -Rf /var/www/"$DName"
                rm -f /var/log/httpd/$DName.error.log
                rm -f /var/log/httpd/$DName.access.log
                rm -f /etc/httpd/conf.d/virtualhost/"$DName".conf

                systemctl restart httpd
                FLAG=0
        fi
        return $FLAG
}

function SuspendDomain
{
        FLAG=3

        source ./00-domainname.sh
        DomainName

        if [ -d /var/www/$Dname ]
                then
                FLAG=4
                if grep -Fq granted /var/www/"$DName"/.htaccess
                        then
                        sed -i "s/granted/denied/g" /var/www/"$DName"/.htaccess
                        FLAG=0
                fi
        fi
        return $FLAG
}

function ResumeDomain
{
        FLAG=5

        source ./00-domainname.sh
        DomainName

        if [ -d /var/www/$Dname ]
                then
                FLAG=6
                if grep -Fq denied /var/www/"$DName"/.htaccess
                        then
                        sed -i "s/denied/granted/g" /var/www/$DName/.htaccess
                        FLAG=0
                fi
        fi
        return $FLAG
}

function ListEnabled
{
        FLAG=7
        if grep -Fq granted /var/www/*/.htaccess 2> /dev/null
                then
                grep -l granted /var/www/*/.htaccess | awk ' BEGIN{ FS="/" } { print $4 }'
                FLAG=0
        fi
        return $FLAG
}

function ListEnabled
{
        FLAG=7
        if grep -Fq denied /var/www/*/.htaccess 2> /dev/null
                then
                grep -l denied /var/www/*/.htaccess | awk ' BEGIN{ FS="/" } { print $4 }'
                FLAG=0
        fi
        return $FLAG
}

