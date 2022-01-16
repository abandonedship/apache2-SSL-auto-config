#/bin/bash

# apache2 SSL TLS auto-configuration

function header(){
	printf "\e[1mapache2 server SSL/TLS auto-configuration script\e[0m\n\n"
}

function usage(){
	printf "Enter your server ip address or your host name \n"
	printf "Example:\n"
	printf "bash apache2-ssl-ac.sh 85.43.1.34\n"
	printf "or\nbash apache2-ssl-ac.sh mydomain.com\n"
}

if [ -z "$1" ]
then
	header
	usage
	exit
fi

current_time=$(date)
old_config_folder="/etc/apache2/sites-available/old_config"

rm -r "$old_config_folder" 2>/dev/null
mkdir "$old_config_folder" 2>/dev/null

header
your_domain="$1"

#####################
# Creating ssl cert #
#####################
#sudo openssl req -x509 -nodes -days 365 -newkey 'rsa:2048' -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -subj '/CN=www.domain.com/O=My Company Name LTD./C=US'
#sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Making backup file default-ssl.conf
printf "[\e[0;32m+\e[0m] Making backup /etc/apache2/sites-available/default-ssl.conf to $old_config_folder/default-ssl.conf.bak.$current_time\n"
sudo cp /etc/apache2/sites-available/default-ssl.conf "$old_config_folder"/default-ssl.conf.bak."$current_time"

# Making backup 000-default.conf.bak
printf "[\e[0;32m+\e[0m] Making backup /etc/apache2/sites-available/000-default.conf to $old_config_folder/000-default.conf.$current_time\n"
cp /etc/apache2/sites-available/000-default.conf "$old_config_folder"/000-default.conf."$current_time"

# Editing file default-ssl.conf
sed -i 's/\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/\/etc\/ssl\/certs\/apache-selfsigned.crt/g' /etc/apache2/sites-available/default-ssl.conf
sed -i 's/\/etc\/ssl\/private\/ssl-cert-snakeoil.key/\/etc\/ssl\/private\/apache-selfsigned.key/g' /etc/apache2/sites-available/default-ssl.conf

# Editing file 000-default.conf
######## REMEMBER CHANGE YOUR DOMAIN OR ASK FOR INPUT
printf "<VirtualHost *:80>\n" > /etc/apache2/sites-available/000-default.conf
printf "        Redirect \"/\" \"https://$your_domain/\"\n" >> /etc/apache2/sites-available/000-default.conf
printf "	ServerAdmin webmaster@localhost\n" >> /etc/apache2/sites-available/000-default.conf
printf "        DocumentRoot /var/www/html\n" >> /etc/apache2/sites-available/000-default.conf
printf "	ErrorLog ${APACHE_LOG_DIR}/error.log\n" >> /etc/apache2/sites-available/000-default.conf
printf "        CustomLog ${APACHE_LOG_DIR}/access.log combined\n" >> /etc/apache2/sites-available/000-default.conf
printf '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# Enabling stuff
printf "[\e[0;32m+\e[0m] Enabling a2enmod ssl\n"
sudo a2enmod ssl
#sudo systemctl restart apache2
printf "[\e[0;32m+\e[0m] Enabling a2enmod headers\n"
sudo a2enmod headers
#sudo systemctl restart apache2
printf "[\e[0;32m+\e[0m] Enabling a2ensite default-ssl\n"
sudo a2ensite default-ssl
#sudo systemctl restart apache2
printf "[\e[0;32m+\e[0m] Running apache2ctl configtest\n"
sudo apache2ctl configtest
printf "[\e[0;32m+\e[0m] Restarting apache2 server\n"
sudo systemctl restart apache2
