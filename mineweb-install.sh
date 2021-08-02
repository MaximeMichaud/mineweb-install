#!/bin/bash
#
# [Script d'installation automatique sur Linux pour MineWeb]
#
# GitHub : https://github.com/MaximeMichaud/mineweb-install
# URL : https://mineweb.org
#
# Ce script est destiné à une installation rapide et facile :
# wget https://github.com/MaximeMichaud/mineweb-install/master/mineweb-install.sh
# chmod +x mineweb-install.sh
# ./mineweb-install.sh
#
# MineWeb-install Copyright (c) 2019-2021 Maxime Michaud
# Licensed under MIT License
#
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included in all
#   copies or substantial portions of the Software.
#
#################################################################################
#Couleurs
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
normal=$(tput sgr0)
alert=${white}${on_red}
on_red=$(tput setab 1)
#################################################################################
function isRoot() {
  if [ "$EUID" -ne 0 ]; then
    return 1
  fi
}

function initialCheck() {
  if ! isRoot; then
    echo "Désolé, vous devez exécuter ce script en tant que root"
    exit 1
  fi
  checkOS
}

# Define versions
PHPMYADMIN_VER=5.1.1
MINEWEB_VER=1.13.0

function checkOS() {
  if [[ -e /etc/debian_version ]]; then
    OS="debian"
    source /etc/os-release

    if [[ "$ID" == "debian" || "$ID" == "raspbian" ]]; then
      if [[ ! $VERSION_ID =~ (9|10|11) ]]; then
        echo "⚠️${alert}Votre version de Debian n'est pas supportée.${normal}"
        echo ""
        echo "${red}Si vous le souhaitez, vous pouvez tout de même continuer."
        echo "Gardez à l'esprit que ce n'est supportée !${normal}"
        echo ""
        until [[ $CONTINUE =~ (y|n) ]]; do
          read -rp "Continuer ? [y/n] : " -e CONTINUE
        done
        if [[ "$CONTINUE" == "n" ]]; then
          exit 1
        fi
      fi
    elif [[ "$ID" == "ubuntu" ]]; then
      OS="ubuntu"
      if [[ ! $VERSION_ID =~ (18.04|20.04) ]]; then
        echo "${alert}Votre version de Ubuntu n'est pas supportée.${normal}"
        echo ""
        echo "${red}Si vous le souhaitez, vous pouvez tout de même continuer."
        echo "Gardez à l'esprit que ce n'est supportée !${normal}"
        echo ""
        until [[ $CONTINUE =~ (y|n) ]]; do
          read -rp "Continuer? [y/n] : " -e CONTINUE
        done
        if [[ "$CONTINUE" == "n" ]]; then
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
        read -rp "Continuer? [y/n] : " -e CONTINUE
      done
      if [[ "$CONTINUE" == "n" ]]; then
        exit 1
      fi
    fi
  else
    echo "${alert}On dirait que vous n'exécutez pas ce script d'installation automatique sur une distribution Debian/Ubuntu ${normal}"
    exit 1
  fi
}

function script() {
  installQuestions
  aptupdate
  aptinstall
  aptinstall_apache2
  aptinstall_mysql
  aptinstall_php
  aptinstall_phpmyadmin
  install_mineweb
  setupdone
}

function installQuestions() {
  echo "${cyan}Bienvenue dans l'installation automatique pour MineWeb !"
  echo "https://github.com/MaximeMichaud/mineweb-install"
  echo "Je dois vous poser quelques questions avant de commencer l'installation."
  echo "Vous pouvez laisser les options par défaut et appuyer simplement sur Entrée si cela vous convient."
  echo ""
  echo "${cyan}Quelle version de PHP ?"
  echo "${red}Rouge = Fin de vie ${yellow}| Jaune = Sécurité uniquement ${green}| Vert = Support & Sécurité"
  echo "${green}   1) PHP 7.4 (recommandé) "
  echo "${yellow}   2) PHP 7.3${normal}${cyan}"
  until [[ "$PHP_VERSION" =~ ^[1-2]$ ]]; do
    read -rp "Version [1-2]: " -e -i 1 PHP_VERSION
  done
  case $PHP_VERSION in
  1)
    PHP="7.4"
    ;;
  2)
    PHP="7.3"
    ;;
  esac
  echo "Which version of MySQL ?"
  echo "${green}   1) MySQL 8.0 ${normal}"
  echo "${red}   2) MySQL 5.7 ${normal}${cyan}"
  until [[ "$DATABASE_VER" =~ ^[1-2]$ ]]; do
    read -rp "Version [1-2]: " -e -i 1 DATABASE_VER
  done
  case $DATABASE_VER in
  1)
    database_ver="8.0"
    ;;
  2)
    database_ver="5.7"
    ;;
  esac
  echo "Quelle version de MineWeb ?"
  echo "   1) Master ($MINEWEB_VER)"
  echo "   2) Développement (Dernière modifications possibles, veuillez prendre Master si vous n'avez aucune raison de prendre développement)"
  until [[ "$MINEWEB_VERSION" =~ ^[1-2]$ ]]; do
    read -rp "Version [1-2]: " -e -i 1 MINEWEB_VERSION
  done
  case $MINEWEB_VERSION in
  1)
    UNZIP="v$MINEWEB_VER.zip"
    MOVE="MineWebCMS-$MINEWEB_VER"
    MOVEZIP="v$MINEWEB_VER.zip"
    ;;
  2)
    UNZIP="development"
    MOVE="MineWebCMS-development"
    MOVEZIP="development.zip"
    ;;
  esac
  echo ""
  echo "Nous sommes prêts à commencer l'installation."
  APPROVE_INSTALL=${APPROVE_INSTALL:-n}
  if [[ $APPROVE_INSTALL =~ n ]]; then
    read -n1 -r -p "Appuyez sur n'importe quelle touche pour continuer..."
  fi
}

function updatepackages() {
  if [[ "$OS" =~ (debian|ubuntu) ]]; then
    apt-get update && apt-get upgrade -y
  elif [[ "$OS" == "centos" ]]; then
    yum -y update
  fi
}

function aptinstall() {
  if [[ "$OS" =~ (debian|ubuntu) ]]; then
    apt-get -y install ca-certificates apt-transport-https dirmngr zip unzip lsb-release gnupg openssl curl wget
  fi
}

function aptinstall_apache2() {
  if [[ "$OS" =~ (debian|ubuntu) ]]; then
    apt-get install -y apache2
    a2enmod rewrite
    wget -O /etc/apache2/sites-available/000-default.conf https://raw.githubusercontent.com/MaximeMichaud/mineweb-install/master/conf/000-default.conf
    service apache2 restart
  fi
}

function aptinstall_mysql() {
  if [[ "$OS" =~ (debian|ubuntu) ]]; then
    echo "MYSQL Installation"
    if [[ "$database_ver" == "8.0" ]]; then
      wget https://raw.githubusercontent.com/MaximeMichaud/mineweb-install/master/conf/default-auth-override.cnf -P /etc/mysql/mysql.conf.d
    fi
    if [[ "$VERSION_ID" =~ (9|10|18.04|20.04) ]]; then
      echo "deb http://repo.mysql.com/apt/$ID/ $(lsb_release -sc) mysql-$database_ver" >/etc/apt/sources.list.d/mysql.list
      echo "deb-src http://repo.mysql.com/apt/$ID/ $(lsb_release -sc) mysql-$database_ver" >>/etc/apt/sources.list.d/mysql.list
      apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5
      apt-get update && apt-get install mysql-server mysql-client -y
      systemctl enable mysql && systemctl start mysql
    fi
    if [[ "$VERSION_ID" == "11" ]]; then
      echo "deb http://repo.mysql.com/apt/debian/ buster mysql-$database_ver" >/etc/apt/sources.list.d/mysql.list
      echo "deb-src http://repo.mysql.com/apt/debian/ buster mysql-$database_ver" >>/etc/apt/sources.list.d/mysql.list
      apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5
      apt-get update && apt-get install mysql-server mysql-client -y
      systemctl enable mysql && systemctl start mysql
    elif [[ "$OS" == "centos" ]]; then
      echo "No Support"
    fi
  fi
}

function aptinstall_php() {
  if [[ "$OS" =~ (debian|ubuntu) ]]; then
    echo "PHP Installation"
    curl -sSL -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    if [[ "$VERSION_ID" =~ (9|10|11) ]]; then
      echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
      apt-get update && apt-get install php$PHP{,-bcmath,-mbstring,-common,-xml,-curl,-gd,-zip,-mysql} -y
      sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 50M|' /etc/php/$PHP/apache2/php.ini
      sed -i 's|post_max_size = 8M|post_max_size = 50M|' /etc/php/$PHP/apache2/php.ini
      sed -i 's|;max_input_vars = 1000|max_input_vars = 2000|' /etc/php/$PHP/apache2/php.ini
      systemctl restart apache2
    fi
    if [[ "$VERSION_ID" =~ (18.04|20.04) ]]; then
      add-apt-repository -y ppa:ondrej/php
      apt-get update && apt-get install php$PHP{,-bcmath,-mbstring,-common,-xml,-curl,-gd,-zip,-mysql} -y
      sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 50M|' /etc/php/$PHP/apache2/php.ini
      sed -i 's|post_max_size = 8M|post_max_size = 50M|' /etc/php/$PHP/apache2/php.ini
      sed -i 's|;max_input_vars = 1000|max_input_vars = 2000|' /etc/php/$PHP/apache2/php.ini
      systemctl restart apache2
    fi
  fi
}

function aptinstall_phpmyadmin() {
  echo "phpMyAdmin Installation"
  if [[ "$OS" =~ (debian|ubuntu) ]]; then
    PHPMYADMIN_VER=$(curl -s "https://api.github.com/repos/phpmyadmin/phpmyadmin/releases/latest" | grep -m1 '^[[:blank:]]*"name":' | cut -d \" -f 4)
    mkdir -p /usr/share/phpmyadmin/ || exit
    wget https://files.phpmyadmin.net/phpMyAdmin/"$PHPMYADMIN_VER"/phpMyAdmin-"$PHPMYADMIN_VER"-all-languages.tar.gz -O /usr/share/phpmyadmin/phpMyAdmin-"$PHPMYADMIN_VER"-all-languages.tar.gz
    tar xzf /usr/share/phpmyadmin/phpMyAdmin-"$PHPMYADMIN_VER"-all-languages.tar.gz --strip-components=1 --directory /usr/share/phpmyadmin
    rm -f /usr/share/phpmyadmin/phpMyAdmin-"$PHPMYADMIN_VER"-all-languages.tar.gz
    # Create phpMyAdmin TempDir
    mkdir -p /usr/share/phpmyadmin/tmp || exit
    chown www-data:www-data /usr/share/phpmyadmin/tmp
    chmod 700 /usr/share/phpmyadmin/tmp
    randomBlowfishSecret=$(openssl rand -base64 32)
    sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret'|" /usr/share/phpmyadmin/config.sample.inc.php >/usr/share/phpmyadmin/config.inc.php
    ln -s /usr/share/phpmyadmin /var/www/phpmyadmin
    wget -O /etc/apache2/sites-available/phpmyadmin.conf https://raw.githubusercontent.com/MaximeMichaud/mineweb-install/master/conf/phpmyadmin.conf
    a2ensite phpmyadmin
    systemctl restart apache2
  elif [[ "$OS" == "centos" ]]; then
    echo "No Support"
  fi
}

function install_mineweb() {
  rm -rf /var/www/html/
  cd /var/www || exit
  wget https://github.com/MineWeb/MineWebCMS/archive/v$MINEWEB_VER.zip
  wget https://github.com/MineWeb/MineWebCMS/archive/development.zip
  mv $MOVEZIP /var/www/
  cd /var/www/ || exit
  unzip -q $UNZIP
  rm -rf v$MINEWEB_VER.zip
  rm -rf development.zip
  mv $MOVE /var/www/html
  chmod -R 755 /var/www/html
  chown -R www-data:www-data /var/www/html
}

function autoUpdate() {
  if [[ "$OS" =~ (debian|ubuntu) ]]; then
    echo "Activation des mises à jour automatique système..."
    apt-get install -y unattended-upgrades
  elif [[ "$OS" == "centos" ]]; then
    echo "No Support"
  fi
}

function setupdone() {
  IP=$(curl 'https://api.ipify.org')
  echo "C'est terminé !"
  echo "${cyan}Configuration Database/User: ${red}http://$IP/"
  echo "${cyan}phpMyAdmin: ${red}http://$IP/phpmyadmin ${normal}${cyan}"
}
function manageMenu() {
  clear
  echo "Bienvenue dans l'installation automatique pour MineWeb !"
  echo "https://github.com/MaximeMichaud/mineweb-install"
  echo ""
  echo "Il semblerait que le Script a déjà été utilisé dans le passé."
  echo ""
  echo "Qu'est-ce que tu veux faire ?"
  echo "   1) Relancer l'installation"
  echo "   2) Mettre à jour phpMyAdmin"
  echo "   3) Ajouter un certificat (https)"
  echo "   4) Mettre à jour le script"
  echo "   5) Quitter"
  until [[ "$MENU_OPTION" =~ ^[1-5]$ ]]; do
    read -rp "Sélectionner une option [1-5] : " MENU_OPTION
  done
  case $MENU_OPTION in
  1)
    script
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

function update() {
  wget https://raw.githubusercontent.com/MaximeMichaud/mineweb-install/master/mineweb-install.sh -O mineweb-install.sh
  chmod +x mineweb-install.sh
  echo ""
  echo "Mise à jour effectuée."
  sleep 2
  ./mineweb-install.sh
  exit
}

function updatephpMyAdmin() {
  if [[ "$OS" =~ (debian|ubuntu) ]]; then
    rm -rf /usr/share/phpmyadmin/*
    cd /usr/share/phpmyadmin/ || exit
    PHPMYADMIN_VER=$(curl -s "https://api.github.com/repos/phpmyadmin/phpmyadmin/releases/latest" | grep -m1 '^[[:blank:]]*"name":' | cut -d \" -f 4)
    wget https://files.phpmyadmin.net/phpMyAdmin/"$PHPMYADMIN_VER"/phpMyAdmin-"$PHPMYADMIN_VER"-all-languages.tar.gz -O /usr/share/phpmyadmin/phpMyAdmin-"$PHPMYADMIN_VER"-all-languages.tar.gz
    tar xzf /usr/share/phpmyadmin/phpMyAdmin-"$PHPMYADMIN_VER"-all-languages.tar.gz --strip-components=1 --directory /usr/share/phpmyadmin
    rm -f /usr/share/phpmyadmin/phpMyAdmin-"$PHPMYADMIN_VER"-all-languages.tar.gz
    # Create TempDir
    mkdir /usr/share/phpmyadmin/tmp || exit
    chown www-data:www-data /usr/share/phpmyadmin/tmp
    chmod 700 /var/www/phpmyadmin/tmp
    randomBlowfishSecret=$(openssl rand -base64 32)
    sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret'|" /usr/share/phpmyadmin/config.sample.inc.php >/usr/share/phpmyadmin/config.inc.php
  elif [[ "$OS" == "centos" ]]; then
    echo "No Support"
  fi
}

initialCheck

if [[ -e /var/www/html/app/ ]]; then
  manageMenu
else
  script
fi