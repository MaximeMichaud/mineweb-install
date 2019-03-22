#!/bin/bash

# Installation automatique pour MineWeb
# https://github.com/fightmaxime/mineweb-install

function isRoot () {
	if [ "$EUID" -ne 0 ]; then
		return 1
	fi
}

function checkOS () {
	if [[ -e /etc/debian_version ]]; then
		OS="debian"
		source /etc/os-release

		if [[ "$ID" == "debian" ]]; then
			if [[ ! $VERSION_ID =~ (8|9) ]]; then
				echo "⚠️ Votre version de Debian n'est pas supportée."
				echo ""
				echo "Si vous le souhaitez, vous pouvez tout de même continuer."
				echo "Gardez à l'esprit que ce n'est supportée !"
				echo ""
				until [[ $CONTINUE =~ (y|n) ]]; do
					read -rp "Continuer? [y/n]: " -e CONTINUE
				done
				if [[ "$CONTINUE" = "n" ]]; then
					exit 1
				fi
			fi
		elif [[ "$ID" == "ubuntu" ]];then
			OS="ubuntu"
			if [[ ! $VERSION_ID =~ (16.04|18.04) ]]; then
				echo "⚠️ Votre version de Ubuntu n'est pas supportée."
				echo ""
				echo "Si vous le souhaitez, vous pouvez tout de même continuer."
				echo "Gardez à l'esprit que ce n'est supportée !"
				echo ""
				until [[ $CONTINUE =~ (y|n) ]]; do
					read -rp "Continuer? [y/n]: " -e CONTINUE
				done
				if [[ "$CONTINUE" = "n" ]]; then
					exit 1
				fi
			fi
		fi
	elif [[ -e /etc/fedora-release ]]; then
		OS=fedora
	elif [[ -e /etc/centos-release ]]; then
		if ! grep -qs "^CentOS Linux release 7" /etc/centos-release; then
			echo "⚠️ Votre version de CentOS n'est pas supportée."
			echo "Gardez à l'esprit que ce n'est supportée !"
			echo ""
			unset CONTINUE
			until [[ $CONTINUE =~ (y|n) ]]; do
				read -rp "Continuer? [y/n]: " -e CONTINUE
			done
			if [[ "$CONTINUE" = "n" ]]; then
				exit 1
			fi
		fi
	else
		echo "On dirait que vous n'exécutez pas ce script d'installation automatique sur une distribution Debian, Ubuntu, Fedora ou CentOS"
		exit 1
	fi
}

function installQuestions () {
	echo "Bienvenue dans l'installation automatique pour MineWeb !"
	echo "https://github.com/fightmaxime/mineweb-install"
	echo ""
	echo "Je dois vous poser quelques questions avant de commencer la configuration."
	echo "Vous pouvez laisser les options par défaut et appuyer simplement sur Entrée si cela vous convient."
	echo ""
	echo ""
	echo ""
	echo ""
	echo "Ok, c'était tout ce dont j'avais besoin. Nous sommes prêts à configurer à commencer l'installation."
	APPROVE_INSTALL=${APPROVE_INSTALL:-n}
	if [[ $APPROVE_INSTALL =~ n ]]; then
		read -n1 -r -p "Appuyez sur n'importe quelle touche pour continuer..."
	fi
}

function installMineWeb () {
	if [[ $AUTO_INSTALL == "y" ]]; then
		#
		APPROVE_INSTALL=${APPROVE_INSTALL:-y}
		CONTINUE=${CONTINUE:-y}
	fi

	#
	installQuestions
	
	if [[ "$OS" =~ (debian|ubuntu) ]]; then
		if [[ "$VERSION_ID" = "8" ]]; then
		    apt update
			apt remove apt-listchanges -y 
			apt upgrade -y
			apt install -y ca-certificates apt-transport-https dirmngr zip unzip
		    wget https://dev.mysql.com/get/mysql-apt-config_0.8.8-1_all.deb
	        ls mysql-apt-config_0.8.8-1_all.deb
	        dpkg -i mysql-apt-config_0.8.8-1_all.deb
	        apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5
	        apt update
	        apt install mysql-server mysql-client -y
	        systemctl enable mysql && systemctl start mysql
		    apt install -y apache2
		    wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
	        echo "deb https://packages.sury.org/php/ jessie main" | tee /etc/apt/sources.list.d/php.list
	        apt update
	        apt install php7.2 libapache2-mod-php7.2 php7.2-mysql php7.2-curl php7.2-json php7.2-gd php7.2-memcached php7.2-intl php7.2-sqlite3 php7.2-gmp php7.2-geoip php7.2-mbstring php7.2-xml php7.2-zip -y
		    service apache2 restart
		    apt install phpmyadmin -y
			rm -rf /usr/share/phpmyadmin/
			mkdir /usr/share/phpmyadmin/
			cd /usr/share/phpmyadmin/
			wget https://files.phpmyadmin.net/phpMyAdmin/4.8.5/phpMyAdmin-4.8.5-all-languages.tar.gz
			tar xzf phpMyAdmin-4.8.5-all-languages.tar.gz
			mv phpMyAdmin-4.8.5-all-languages/* /usr/share/phpmyadmin
			rm /usr/share/phpmyadmin/phpMyAdmin-4.8.5-all-languages.tar.gz
			rm -rf /usr/share/phpmyadmin/phpMyAdmin-4.8.5-all-languages
		    if ! grep -q "Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf; then
		    echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
	        fi
		    a2enmod rewrite
		    wget http://mineweb.maximemichaud.me/000-default.conf
		    mv 000-default.conf /etc/apache2/sites-available/
	        rm -rf 000-default.conf
		    service apache2 restart
		    rm -rf /var/www/html/
		    wget https://github.com/MineWeb/MineWebCMS/archive/v1.7.0.zip
		    mv *.zip /var/www/
		    cd /var/www/
		    unzip *.zip
		    rm -rf *.zip
		    mv MineWebCMS-1.7.0 /var/www/html
		    chmod -R 777 /var/www/html
		fi
		if [[ "$VERSION_ID" = "9" ]]; then
		    apt update
			apt -y install ca-certificates apt-transport-https dirmngr
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
			#mem-cached et geoip à check
	        apt install php7.2 libapache2-mod-php7.2 php7.2-mysql php7.2-curl php7.2-json php7.2-gd php7.2-memcached php7.2-intl php7.2-sqlite3 php7.2-gmp php7.2-geoip php7.2-mbstring php7.2-xml php7.2-zip -y
		    service apache2 restart
		    apt-get install -y phpmyadmin
			rm -rf /usr/share/phpmyadmin/
			mkdir /usr/share/phpmyadmin/
			cd /usr/share/phpmyadmin/
			wget https://files.phpmyadmin.net/phpMyAdmin/4.8.5/phpMyAdmin-4.8.5-all-languages.tar.gz
			tar xzf phpMyAdmin-4.8.5-all-languages.tar.gz
			mv phpMyAdmin-4.8.5-all-languages/* /usr/share/phpmyadmin
			rm /usr/share/phpmyadmin/phpMyAdmin-4.8.5-all-languages.tar.gz
			rm -rf /usr/share/phpmyadmin/phpMyAdmin-4.8.5-all-languages
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
		fi	
		if [[ "$VERSION_ID" = "16.04|18.04" ]]; then
			apt-get update
		fi
	elif [[ "$OS" = 'centos' ]]; then
		yum install -y epel-release
	elif [[ "$OS" = 'fedora' ]]; then
		dnf install -y wget ca-certificates curl
	fi
}


function initialCheck () {
	if ! isRoot; then
		echo "Désolé, vous devez l'exécuter en tant que root."
		exit 1
	fi
	checkOS
}

function manageMenu () {
	clear
	echo "Bienvenue dans l'installation automatique pour MineWeb !"
	echo "https://github.com/fightmaxime/mineweb-install"
	echo ""
	echo "On dirait que MineWeb est déjà installé."
	echo ""
	echo "Qu'est-ce que tu veux faire?"
	echo "   1) Installation automatique"
	echo "   2) Mettre à jour le script"
	echo "   3) Quitter"
	until [[ "$MENU_OPTION" =~ ^[1-3]$ ]]; do
		read -rp "Sélectionner une option [1-3]: " MENU_OPTION
	done

	case $MENU_OPTION in
		1)
			installMineWeb
		;;
		2)
			update
		;;
		3)
			exit 0
		;;
	esac
}

function update () {
	    wget https://raw.githubusercontent.com/fightmaxime/mineweb-install/development/mineweb-install.sh -O mineweb-install.sh
		chmod +x mineweb-install.sh
		echo ""
		echo "Mise à jour effectuée."
		sleep 2
		./mineweb-install.sh
		exit
}

# ...
initialCheck

# Vérifier si MineWeb est déjà installé
if [[ -e /var/www/html/app/index.php ]]; then
	manageMenu
else
	installMineWeb
fi
