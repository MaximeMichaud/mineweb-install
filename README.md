# MineWeb-install
[![Travis CI](https://travis-ci.com/MaximeMichaud/mineweb-install.svg?branch=master)](https://travis-ci.com/MaximeMichaud/mineweb-install)
## Usage
```sh
wget https://raw.githubusercontent.com/MaximeMichaud/mineweb-install/master/mineweb-install.sh
chmod +x mineweb-install.sh
./mineweb-install.sh
```
[Indications concernant l'installation par 󠂪󠂪DarkScientist_](https://github.com/MaximeMichaud/mineweb-install/wiki/Tutoriel-par-%F3%A0%82%AA%F3%A0%82%AADarkScientist_)

## Compatibilité
Veuillez considérer les dernières versions comme étant plus stable.

Le script supporte ces OS:

|        |   |
|--------|---|
| Debian 8 | ❌  |
| Debian 9 | ✅ |
| Debian 10 | ✅ |
| Ubuntu 16.04 | ✅  |
| Ubuntu 18.04 | ✅  |
| CentOS 7 | ❌  |
## Features
* MySQL 5.6 à 8.0 (ne pas prendre le SHA de 8.0)
* PHP 5.6 à 7.4
* phpMyAdmin 4.9.0.1
## To-Do
* ~~Choix de la version MineWeb & PHP~~
* ~~phpMyAdmin à la dernière version~~
* ~~Php 7.3, puisqu'il est supporté depuis~~ [#5](https://github.com/MineWeb/MineWebCMS/pull/5/),  [#100](https://github.com/MineWeb/MineWebCMS/pull/100/) ---> phpMyAdmin ne le supporte pas encore officiellement.
* Possibilité de choisir nginx au lieu de apache2
* Ajout d'un message comme quoi l'installation est terminé
* ~Fonction pour mettre à jour phpMyAdmin~ & php
* Let's Encrypt
* ~Augmenter la limite d'upload de PHP pour phpMyAdmin~
* Vérification une installation précédente (Sans script) a été tentée avec confirmation
* Plus d'informations lors de l'installation (À la fin et pendant)
* mysql_secure_installation (automatique)
* Un peu de couleurs
* ~~mysql-apt-config_0.8.13-1_all.deb~~
* ~~PHP 7.4~~
* Configuration MYSQL
* Améliorer la configuration apache2 (check if apache2 installed first)
* Update de sécurité automatique
* Possibilité de upgrade de version PHP
* Création de la base de donnée automatique sur demande
* ~Support de CloudFlare~
* Branch Dev ou Master (Confirmé, master porte les mêmes commits que la dernière release)
* Précisé s'ils veulent update le host au début
* Configuration automatique de l'utilisateur et du CMS à partir du script
* ~~Supporté Debian 8, Ubuntu 16.04 & 18.04~~ (CentOS, seulement si demandé)
## FAQ
**MERCI DE REGARDER LE [WIKI](https://github.com/MaximeMichaud/mineweb-install/wiki/FAQ)**
