#!/bin/bash
#
# [Installation automatique pour MineWeb]
# https://github.com/MaximeMichaud/mineweb-install
#################################################################################
#Couleurs
black=$(tput setaf 0); red=$(tput setaf 1); green=$(tput setaf 2); yellow=$(tput setaf 3);
blue=$(tput setaf 4); magenta=$(tput setaf 5); cyan=$(tput setaf 6); white=$(tput setaf 7);
on_red=$(tput setab 1); on_green=$(tput setab 2); on_yellow=$(tput setab 3); on_blue=$(tput setab 4);
on_magenta=$(tput setab 5); on_cyan=$(tput setab 6); on_white=$(tput setab 7); bold=$(tput bold);
dim=$(tput dim); underline=$(tput smul); reset_underline=$(tput rmul); standout=$(tput smso);
reset_standout=$(tput rmso); normal=$(tput sgr0); alert=${white}${on_red}; title=${standout};
sub_title=${bold}${yellow}; repo_title=${black}${on_green}; message_title=${white}${on_magenta}
#################################################################################
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
			if [[ ! $VERSION_ID =~ (8|9|10) ]]; then
				echo "${alert}Votre version de Debian n'est pas supportée.${normal}"
				echo ""
				echo "${red}Si vous le souhaitez, vous pouvez tout de même continuer."
				echo "Gardez à l'esprit que ce n'est supportée !${normal}"
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
				echo "${alert}Votre version de Ubuntu n'est pas supportée.${normal}"
				echo ""
				echo "${red}Si vous le souhaitez, vous pouvez tout de même continuer."
				echo "Gardez à l'esprit que ce n'est supportée !${normal}"
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
			echo "${alert}Votre version de CentOS n'est pas supportée.${normal}"
			echo "${red}Gardez à l'esprit que ce n'est supportée !${normal}"
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
		echo "${alert}On dirait que vous n'exécutez pas ce script d'installation automatique sur une distribution Debian, Ubuntu, Fedora ou CentOS ${normal}"
		exit 1
	fi
}

function installQuestions () {
	echo "${cyan}Bienvenue dans l'installation automatique pour MineWeb !"
	echo "https://github.com/MaximeMichaud/mineweb-install"
	echo ""
	echo "Je dois vous poser quelques questions avant de commencer la configuration."
	echo "Vous pouvez laisser les options par défaut et appuyer simplement sur Entrée si cela vous convient."
	echo ""
	echo "Quelle version de PHP ?"
	echo "${red}Rouge = Fin de vie ${yellow}Jaune = Sécurité uniquement ${green}Vert = Support & Sécurité"
	echo "${red}   1) PHP 5.6 "
	echo "   2) PHP 7.0 "
	echo "${yellow}   3) PHP 7.1 "
	echo "${green}   4) PHP 7.2 "
	echo "   5) PHP 7.3 (recommandé) "
	echo "   6) PHP 7.4 (${red}non supporté officiellement par phpMyAdmin & MineWeb)${normal}${cyan}"
	until [[ "$PHP_VERSION" =~ ^[1-6]$ ]]; do
		read -rp "Version [1-6]: " -e -i 5 PHP_VERSION
	done
	case $PHP_VERSION in
		1)
			PHP="5.6"
		;;
		2)
			PHP="7.0"
		;;
		3)
			PHP="7.1"
		;;
		4)
			PHP="7.2"
		;;
		5)
			PHP="7.3"
		;;
		6)
			PHP="7.4"
		;;
	esac
	echo "Quelle version de MineWeb ?"
	echo "   1) Master (1.7.0)"
	echo "   2) Développement (Dernière modifications possible, recommandé)"
	until [[ "$MINEWEB_VERSION" =~ ^[1-5]$ ]]; do
		read -rp "Version [1-2]: " -e -i 2 MINEWEB_VERSION
	done
	case $MINEWEB_VERSION in
		1)
			UNZIP="v1.7.0.zip"
			MOVE="MineWebCMS-1.7.0"
			MOVEZIP="v1.7.0.zip"
		;;
		2)
			UNZIP="development"
			MOVE="MineWebCMS-development"
			MOVEZIP="development.zip"
		;;
	esac
#	echo "Souhaitez-vous supporter CloudFlare ?"
#	echo "Si vous refusez, il sera tout de même possible de le supporter en relaçant le script"
#	echo "Cela ne cause aucun souci d'accepter, même si vous n'utilisez pas CloudFlare dans l'immédiat."
#	echo "   1) Oui (recommandé)"
#	echo "   2) Non"
#	until [[ "$CLOUDFLARE_SUPPORT" =~ ^[1-2]$ ]]; do
#		read -rp "Version [1-2]: " -e -i 1 CLOUDFLARE_SUPPORT
#	done
#	case $CLOUDFLARE_SUPPORT in
#		1)
#		   apt update && cd /root/
#	       apt-get install libtool apache2-dev -y
#	       wget https://www.cloudflare.com/static/misc/mod_cloudflare/mod_cloudflare.c
#	       apxs -a -i -c mod_cloudflare.c
#	       apxs2 -a -i -c mod_cloudflare.c
#		   systemctl restart apache2
#		;;
#		2)
#		;;
#	esac
#	echo "Souhaitez-vous améliorer la sécurité ?"
#	echo "Si vous refusez, ce sera à vous de vous en occuper"
#	echo "Cela n'influencera pas l'installation du CMS. "
#	echo "   1) Oui (recommandé)"
#	echo "   2) Non"
#	until [[ "$CLOUDFLARE_SUPPORT" =~ ^[1-2]$ ]]; do
#		read -rp "Version [1-2]: " -e -i 1 CLOUDFLARE_SUPPORT
#	done
#	case $CLOUDFLARE_SUPPORT in
#		1) #À REFAIRE
#		   apt update
#		   apt install apache2-dev apache2 libtool git -y
#		   git clone https://github.com/cloudflare/mod_cloudflare.git; cd mod_cloudflare
#		   apxs -a -i -c mod_cloudflare.
#		   apachectl restart; apache2ctl -M|grep cloudflare
#		;;
#		2)
#		;;
	echo "Nous sommes prêts à commencer l'installation."
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
		MINEWEB_VERSION=${MINEWEB_CHOICE:-1}
		PHP_VERSION=${PHP_VERSION:-1}
	fi

	#
	installQuestions
	
	if [[ "$OS" =~ (debian|ubuntu) ]]; then
		if [[ "$VERSION_ID" = "8" ]]; then
		    rm -rf /etc/apt/sources.list
                    echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list
                    echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
                    sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list
		    apt-get -o Acquire::Check-Valid-Until=false update
		    apt remove apt-listchanges -y 
		    apt upgrade -y
		    apt install -y ca-certificates apt-transport-https dirmngr zip unzip sudo lsb-release
		    echo "deb https://repo.mysql.com/apt/debian/ jessie mysql-8.0" | sudo tee /etc/apt/sources.list.d/mysql.list
			echo "deb-src https://repo.mysql.com/apt/debian/ jessie mysql-8.0" | sudo tee /etc/apt/sources.list.d/mysql.list
	        apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5
	        apt-get -o Acquire::Check-Valid-Until=false update
	        apt install --allow-unauthenticated mysql-server mysql-client -y
	        systemctl enable mysql && systemctl start mysql
		    apt install -y apache2
		    wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
	        echo "deb https://packages.sury.org/php/ jessie main" | tee /etc/apt/sources.list.d/php.list
		    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	        apt-get -o Acquire::Check-Valid-Until=false update
	        apt install php$PHP libapache2-mod-php$PHP php$PHP-mysql php$PHP-curl php$PHP-json php$PHP-gd php$PHP-memcached php$PHP-intl php$PHP-sqlite3 php$PHP-gmp php$PHP-geoip php$PHP-mbstring php$PHP-xml php$PHP-zip -y
			sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 20M|' /etc/php/$PHP/apache2/php.ini
            sed -i 's|post_max_size = 8M|post_max_size = 20M|' /etc/php/$PHP/apache2/php.ini
		    service apache2 restart
		    apt install phpmyadmin -y
		    rm -rf /usr/share/phpmyadmin/
		    mkdir /usr/share/phpmyadmin/
		    cd /usr/share/phpmyadmin/
		    wget https://files.phpmyadmin.net/phpMyAdmin/4.9.1/phpMyAdmin-4.9.1-all-languages.tar.gz
		    tar xzf phpMyAdmin-4.9.1-all-languages.tar.gz
		    mv phpMyAdmin-4.9.1-all-languages/* /usr/share/phpmyadmin
		    rm /usr/share/phpmyadmin/phpMyAdmin-4.9.1-all-languages.tar.gz
		    rm -rf /usr/share/phpmyadmin/phpMyAdmin-4.9.1-all-languages
		    if ! grep -q "Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf; then
		    echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
	        fi
			mkdir /usr/share/phpmyadmin/tmp
            chmod 777 /usr/share/phpmyadmin/tmp
			randomBlowfishSecret=`openssl rand -base64 32`;
            sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret'|" config.sample.inc.php > config.inc.php
		    a2enmod rewrite
		    wget http://mineweb.maximemichaud.me/000-default.conf
		    mv 000-default.conf /etc/apache2/sites-available/
	        rm -rf 000-default.conf
		    service apache2 restart
		    rm -rf /var/www/html/
			cd /var/wwww
		    wget https://github.com/MineWeb/MineWebCMS/archive/v1.7.0.zip
		    wget https://github.com/MineWeb/MineWebCMS/archive/development.zip
		    mv $MOVEZIP /var/www/
		    cd /var/www/
		    unzip -q $UNZIP
		    rm -rf $UNZIP
		    mv $MOVE /var/www/html
            chmod -R 777 /var/www/html
		fi
		if [[ "$VERSION_ID" = "9" ]]; then
		    apt update
		    apt -y install ca-certificates apt-transport-https dirmngr unzip sudo lsb-release
			echo "deb https://repo.mysql.com/apt/debian/ stretch mysql-8.0" | sudo tee /etc/apt/sources.list.d/mysql.list
			echo "deb-src https://repo.mysql.com/apt/debian/ stretch mysql-8.0" | sudo tee /etc/apt/sources.list.d/mysql.list
	        apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5
	        apt update
	        apt install --allow-unauthenticated mysql-server mysql-client -y
	        systemctl enable mysql && systemctl start mysql
		    apt install -y apache2
		    wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
	        echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list
	        apt update
		    #mem-cached et geoip à check
	        apt install php$PHP libapache2-mod-php$PHP php$PHP-mysql php$PHP-curl php$PHP-json php$PHP-gd php$PHP-memcached php$PHP-intl php$PHP-sqlite3 php$PHP-gmp php$PHP-geoip php$PHP-mbstring php$PHP-xml php$PHP-zip -y
		    service apache2 restart
			sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 20M|' /etc/php/$PHP/apache2/php.ini
            sed -i 's|post_max_size = 8M|post_max_size = 20M|' /etc/php/$PHP/apache2/php.ini
		    apt install -y phpmyadmin
		    rm -rf /usr/share/phpmyadmin/
		    mkdir /usr/share/phpmyadmin/
		    cd /usr/share/phpmyadmin/
		    wget https://files.phpmyadmin.net/phpMyAdmin/4.9.1/phpMyAdmin-4.9.1-all-languages.tar.gz
		    tar xzf phpMyAdmin-4.9.1-all-languages.tar.gz
		    mv phpMyAdmin-4.9.1-all-languages/* /usr/share/phpmyadmin
		    rm /usr/share/phpmyadmin/phpMyAdmin-4.9.1-all-languages.tar.gz
		    rm -rf /usr/share/phpmyadmin/phpMyAdmin-4.9.1-all-languages
		    if ! grep -q "Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf; then
		    echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
	        fi
			mkdir /usr/share/phpmyadmin/tmp
            chmod 777 /usr/share/phpmyadmin/tmp
			randomBlowfishSecret=`openssl rand -base64 32`;
            sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret'|" config.sample.inc.php > config.inc.php
		    a2enmod rewrite
		    wget http://mineweb.maximemichaud.me/000-default.conf
		    mv 000-default.conf /etc/apache2/sites-available/
	        rm -rf 000-default.conf
		    service apache2 restart
		    apt install zip -y
		    rm -rf /var/www/html/
			cd /var/wwww
		    wget https://github.com/MineWeb/MineWebCMS/archive/v1.7.0.zip
		    wget https://github.com/MineWeb/MineWebCMS/archive/development.zip
		    mv $MOVEZIP /var/www/
		    cd /var/www/
		    unzip -q $UNZIP
		    rm -rf $UNZIP
		    mv $MOVE /var/www/html
            chmod -R 777 /var/www/html
	    fi
		if [[ "$VERSION_ID" = "10" ]]; then
		    apt update
		    apt -y install ca-certificates apt-transport-https dirmngr unzip sudo lsb-release
		    echo "deb https://repo.mysql.com/apt/debian/ buster mysql-8.0" | sudo tee /etc/apt/sources.list.d/mysql.list
			echo "deb-src https://repo.mysql.com/apt/debian/ buster mysql-8.0" | sudo tee /etc/apt/sources.list.d/mysql.list
	        apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5
	        apt update
	        apt install --allow-unauthenticated mysql-server mysql-client -y
	        systemctl enable mysql && systemctl start mysql
		    apt install -y apache2
		    wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
	        echo "deb https://packages.sury.org/php/ buster main" | sudo tee /etc/apt/sources.list.d/php.list
	        apt update
		    #mem-cached et geoip à check
	        apt install php$PHP libapache2-mod-php$PHP php$PHP-mysql php$PHP-curl php$PHP-json php$PHP-gd php$PHP-memcached php$PHP-intl php$PHP-sqlite3 php$PHP-gmp php$PHP-geoip php$PHP-mbstring php$PHP-xml php$PHP-zip -y
			sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 20M|' /etc/php/$PHP/apache2/php.ini
            sed -i 's|post_max_size = 8M|post_max_size = 20M|' /etc/php/$PHP/apache2/php.ini
		    service apache2 restart
		    mkdir /usr/share/phpmyadmin/
		    cd /usr/share/phpmyadmin/
		    wget https://files.phpmyadmin.net/phpMyAdmin/4.9.1/phpMyAdmin-4.9.1-all-languages.tar.gz
		    tar xzf phpMyAdmin-4.9.1-all-languages.tar.gz
		    mv phpMyAdmin-4.9.1-all-languages/* /usr/share/phpmyadmin
		    rm /usr/share/phpmyadmin/phpMyAdmin-4.9.1-all-languages.tar.gz
		    rm -rf /usr/share/phpmyadmin/phpMyAdmin-4.9.1-all-languages
			wget http://mineweb.maximemichaud.me/phpmyadmin.conf
			mv phpmyadmin.conf /etc/apache2/sites-available/
			mkdir /usr/share/phpmyadmin/tmp
            chmod 777 /usr/share/phpmyadmin/tmp
			randomBlowfishSecret=`openssl rand -base64 32`;
            sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret'|" config.sample.inc.php > config.inc.php
			a2ensite phpmyadmin
			systemctl restart apache2
		    a2enmod rewrite
		    wget http://mineweb.maximemichaud.me/000-default.conf
		    mv 000-default.conf /etc/apache2/sites-available/
	        rm -rf 000-default.conf
		    service apache2 restart
		    apt install zip -y
		    rm -rf /var/www/html/
			cd /var/wwww
		    wget https://github.com/MineWeb/MineWebCMS/archive/v1.7.0.zip
		    wget https://github.com/MineWeb/MineWebCMS/archive/development.zip
		    mv $MOVEZIP /var/www/
		    cd /var/www/
		    unzip -q $UNZIP
		    rm -rf $UNZIP
		    mv $MOVE /var/www/html
            chmod -R 777 /var/www/html
		fi	
		if [[ "$VERSION_ID" = "16.04" ]]; then
			apt update
			apt -y install ca-certificates apt-transport-https dirmngr software-properties-common lsb-release
		    wget https://dev.mysql.com/get/mysql-apt-config_0.8.8-1_all.deb
	        ls mysql-apt-config_0.8.8-1_all.deb
	        dpkg -i mysql-apt-config_0.8.8-1_all.deb
	        apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5
	        apt update
	        apt install --allow-unauthenticated mysql-server mysql-client -y
	        systemctl enable mysql && systemctl start mysql
			add-apt-repository -y ppa:ondrej/apache2
			apt update
		    apt install -y apache2
		    add-apt-repository -y ppa:ondrej/php
	        apt update
			#mem-cached et geoip à check
	        apt install php$PHP libapache2-mod-php$PHP php$PHP-mysql php$PHP-curl php$PHP-json php$PHP-gd php$PHP-memcached php$PHP-intl php$PHP-sqlite3 php$PHP-gmp php$PHP-geoip php$PHP-mbstring php$PHP-xml php$PHP-zip -y
			sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 20M|' /etc/php/$PHP/apache2/php.ini
            sed -i 's|post_max_size = 8M|post_max_size = 20M|' /etc/php/$PHP/apache2/php.ini
		    service apache2 restart
		    apt install -y phpmyadmin
			rm -rf /usr/share/phpmyadmin/
			mkdir /usr/share/phpmyadmin/
			cd /usr/share/phpmyadmin/
			wget https://files.phpmyadmin.net/phpMyAdmin/4.9.1/phpMyAdmin-4.9.1-all-languages.tar.gz
		    tar xzf phpMyAdmin-4.9.1-all-languages.tar.gz
		    mv phpMyAdmin-4.9.1-all-languages/* /usr/share/phpmyadmin
		    rm /usr/share/phpmyadmin/phpMyAdmin-4.9.1-all-languages.tar.gz
		    rm -rf /usr/share/phpmyadmin/phpMyAdmin-4.9.1-all-languages
		    if ! grep -q "Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf; then
		    echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
	        fi
			mkdir /usr/share/phpmyadmin/tmp
            chmod 777 /usr/share/phpmyadmin/tmp
			randomBlowfishSecret=`openssl rand -base64 32`;
            sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret'|" config.sample.inc.php > config.inc.php
		    a2enmod rewrite
		    wget http://mineweb.maximemichaud.me/000-default.conf
		    mv 000-default.conf /etc/apache2/sites-available/
	        rm -rf 000-default.conf
		    service apache2 restart
		    apt install zip -y
		    rm -rf /var/www/html/
			cd /var/wwww
		    wget https://github.com/MineWeb/MineWebCMS/archive/v1.7.0.zip
		    wget https://github.com/MineWeb/MineWebCMS/archive/development.zip
		    mv $MOVEZIP /var/www/
		    cd /var/www/
		    unzip -q $UNZIP
		    rm -rf $UNZIP
		    mv $MOVE /var/www/html
            chmod -R 777 /var/www/html
		fi
		if [[ "$VERSION_ID" = "18.04" ]]; then
			apt update
			apt -y install ca-certificates apt-transport-https dirmngr software-properties-common lsb-release
		    wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb
	        ls mysql-apt-config_0.8.13-1_all.deb
	        dpkg -i mysql-apt-config_0.8.13-1_all.deb
	        apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5
	        apt update
	        apt install --allow-unauthenticated mysql-server mysql-client -y
	        systemctl enable mysql && systemctl start mysql
			add-apt-repository -y ppa:ondrej/apache2
			apt update
		    apt install -y apache2
		    add-apt-repository -y ppa:ondrej/php
	        apt update
			#mem-cached et geoip à check
	        apt install php$PHP libapache2-mod-php$PHP php$PHP-mysql php$PHP-curl php$PHP-json php$PHP-gd php$PHP-memcached php$PHP-intl php$PHP-sqlite3 php$PHP-gmp php$PHP-geoip php$PHP-mbstring php$PHP-xml php$PHP-zip -y
			sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 20M|' /etc/php/$PHP/apache2/php.ini
            sed -i 's|post_max_size = 8M|post_max_size = 20M|' /etc/php/$PHP/apache2/php.ini
		    service apache2 restart
		    apt install -y phpmyadmin
			rm -rf /usr/share/phpmyadmin/
			mkdir /usr/share/phpmyadmin/
			cd /usr/share/phpmyadmin/
			wget https://files.phpmyadmin.net/phpMyAdmin/4.9.1/phpMyAdmin-4.9.1-all-languages.tar.gz
		    tar xzf phpMyAdmin-4.9.1-all-languages.tar.gz
		    mv phpMyAdmin-4.9.1-all-languages/* /usr/share/phpmyadmin
		    rm /usr/share/phpmyadmin/phpMyAdmin-4.9.1-all-languages.tar.gz
		    rm -rf /usr/share/phpmyadmin/phpMyAdmin-4.9.1-all-languages
		    if ! grep -q "Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf; then
		    echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
	        fi
			mkdir /usr/share/phpmyadmin/tmp
            chmod 777 /usr/share/phpmyadmin/tmp
			randomBlowfishSecret=`openssl rand -base64 32`;
            sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret'|" config.sample.inc.php > config.inc.php
		    a2enmod rewrite
		    wget http://mineweb.maximemichaud.me/000-default.conf
		    mv 000-default.conf /etc/apache2/sites-available/
	        rm -rf 000-default.conf
		    service apache2 restart
		    apt install zip -y
		    rm -rf /var/www/html/
			cd /var/wwww
		    wget https://github.com/MineWeb/MineWebCMS/archive/v1.7.0.zip
		    wget https://github.com/MineWeb/MineWebCMS/archive/development.zip
		    mv $MOVEZIP /var/www/
		    cd /var/www/
		    unzip -q $UNZIP
		    rm -rf $UNZIP
		    mv $MOVE /var/www/html
            chmod -R 777 /var/www/html
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
	echo "https://github.com/MaximeMichaud/mineweb-install"
	echo ""
	echo "Il semblerait que MineWeb soit déjà installé."
	echo ""
	echo "Qu'est-ce que tu veux faire?"
	echo "   1) Relancer l'installation"
	echo "   2) Mettre à jour phpMyAdmin"
	echo "   3) Ajouter un certificat (https)"
	echo "   4) Mettre à jour le script"
	echo "   5) Quitter"
	until [[ "$MENU_OPTION" =~ ^[1-4]$ ]]; do
		read -rp "Sélectionner une option [1-4]: " MENU_OPTION
	done

	case $MENU_OPTION in
		1)
			installMineWeb
		;;
		2)
			updatephpMyAdmin
		;;
		3)
			install_letsencrypt
		;;
		4)
			update
		;;
		5)
			exit 0
		;;
	esac
}

function update () {
	    wget https://raw.githubusercontent.com/MaximeMichaud/mineweb-install/master/mineweb-install.sh -O mineweb-install.sh
		chmod +x mineweb-install.sh
		echo ""
		echo "Mise à jour effectuée."
		sleep 2
		./mineweb-install.sh
		exit
}

function updatephpMyAdmin () {
	                rm -rf /usr/share/phpmyadmin/
			        mkdir /usr/share/phpmyadmin/
			        cd /usr/share/phpmyadmin/
			        wget https://files.phpmyadmin.net/phpMyAdmin/4.9.1/phpMyAdmin-4.9.1-all-languages.tar.gz
		            tar xzf phpMyAdmin-4.9.1-all-languages.tar.gz
		            mv phpMyAdmin-4.9.1-all-languages/* /usr/share/phpmyadmin
		            rm /usr/share/phpmyadmin/phpMyAdmin-4.9.1-all-languages.tar.gz
		            rm -rf /usr/share/phpmyadmin/phpMyAdmin-4.9.1-all-languages
					mkdir /usr/share/phpmyadmin/tmp
                    chmod 777 /usr/share/phpmyadmin/tmp
					randomBlowfishSecret=`openssl rand -base64 32`;
                    sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret'|" config.sample.inc.php > config.inc.php
}

function install_letsencrypt () {
            service apache2 stop
            apt -y -qq install socat cron
	        echo -ne "Veuillez entrer un mail pour le certificat: " ; read EMAIL
		    echo -ne "Veuillez entrer le nom de domaine (monserveur.fr): " ; read DOMAIN
			cd /root
            mkdir -p /etc/apache2/ssl/{site,certs}
            git clone https://github.com/Neilpang/acme.sh.git acme.sh-master
            cd /root/acme.sh-master
			./acme.sh --install --accountconf /etc/apache2/ssl/site/$DOMAIN.conf --accountkey /etc/apache2/ssl/site/$DOMAIN.key --accountemail "$EMAIL"
            ./acme.sh --issue --standalone --keypath /etc/apache2/ssl/certs/$DOMAIN-ssl.key --fullchainpath /etc/apache2/ssl/certs/$DOMAIN-ssl.pem -d $DOMAIN
            sed -i -e "s/SSLCertificateFile \/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/SSLCertificateFile \/etc\/apache2\/ssl\/certs\/$DOMAIN-ssl.pem/g" /etc/apache2/sites-enabled/default-ssl.conf
            sed -i -e "s/SSLCertificateKeyFile \/etc\/ssl\/private\/ssl-cert-snakeoil.key/SSLCertificateKeyFile \/etc\/apache2\/ssl\/certs\/$DOMAIN-ssl.key/g" /etc/apache2/sites-enabled/default-ssl.conf
			line="30 2 * * 1 "~/acme.sh-master"/acme.sh --cron --home "~/acme.sh" > /dev/null"
            (crontab -u root -l; echo "$line" ) | crontab -u root -
            service apache2 restart
}

function installcloudflare () {
            apt update && cd /root/
	        apt-get install libtool apache2-dev
	        wget https://www.cloudflare.com/static/misc/mod_cloudflare/mod_cloudflare.c
	        apxs -a -i -c mod_cloudflare.c
	        apxs2 -a -i -c mod_cloudflare.c
			systemctl restart apache2
}

# STRUCTURE
initialCheck

# Vérifier si MineWeb est déjà installé
if [[ -e /var/www/html/app/index.php ]]; then
	manageMenu
else
	installMineWeb
fi
