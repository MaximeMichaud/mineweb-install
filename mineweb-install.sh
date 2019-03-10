#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
	echo -e "Désolé, vous devez l'exécuter en tant que root."
	exit 1
fi
echo ""
echo "MineWeb-install"
echo ""
echo "Qu'est-ce que tu veux faire ?"
echo "   1) Installation automatique"
echo "   2) Mettre à jour le script"
echo "   3) Quitter"
echo ""
while [[ $OPTION !=  "1" && $OPTION !=  "2" && $OPTION != "3" ]]; do
	read -p "Sélectionner une option [1-3]: " OPTION
done
case $OPTION in
    1) # Automatique
		apt-get update && apt-get -y upgrade
		apt install ca-certificates apt-transport-https dirmngr -y
		wget https://dev.mysql.com/get/mysql-apt-config_0.8.8-1_all.deb
	    ls mysql-apt-config_0.8.8-1_all.deb
	    dpkg -i mysql-apt-config_0.8.8-1_all.deb
	    apt install dirmngr -y
	    apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5
	    apt update
	    apt install mysql-server mysql-client -y
	    systemctl enable mysql && systemctl start mysql
		apt-get install -y apache2
		wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
	    echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list
	    apt update
	    apt install php7.2 libapache2-mod-php7.2 php7.2-mysql php7.2-curl php7.2-json php7.2-gd php7.2-memcached php7.2-intl php7.2-sqlite3 php7.2-gmp php7.2-geoip php7.2-mbstring php7.2-xml php7.2-zip -y
		service apache2 restart
		apt-get install -y phpmyadmin
		if ! grep -q "Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf; then
		echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
	    fi
		a2enmod rewrite
		wget http://mineweb.maximemichaud.me/000-default.conf
		mv 000-default.conf /etc/apache2/sites-available/
	    rm -rf 000-default.conf
		service apache2 restart
		apt install zip -y
		rm -rf /var/www/html/
		wget https://github.com/MineWeb/MineWebCMS/archive/v1.7.0.zip
		mv *.zip /var/www/
		cd /var/www/
		unzip *.zip
		rm -rf *.zip
		mv MineWebCMS-1.7.0 /var/www/html
		chmod -R 777 /var/www/html
	;;
	2)
		wget https://raw.githubusercontent.com/fightmaxime/mineweb-install/master/mineweb-install.sh -O mineweb-install.sh
		chmod +x mineweb-install.sh
		echo ""
		echo "Update done."
		sleep 2
		./mineweb-install.sh
		exit
	;;
	3) # Exit
		exit
	;;

esac
