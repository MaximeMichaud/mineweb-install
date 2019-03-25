# MineWeb-install
[![Travis CI](https://travis-ci.com/fightmaxime/mineweb-install.svg?branch=master)](https://travis-ci.com/fightmaxime/mineweb-install)
## Usage
```sh
wget https://raw.githubusercontent.com/fightmaxime/mineweb-install/development/mineweb-install.sh
chmod +x mineweb-install.sh
./mineweb-install.sh
```
## Compatibilité
Veuillez considérer les dernières versions comme étant plus stable.

Le script supporte ces OS:

|        |   |
|--------|---|
| Debian 8 | ✅  |
| Debian 9 | ✅ |
| Ubuntu 16.04 | ✅  |
| Ubuntu 18.04 | ✅  |
| CentOS 7 | ❌  |
| Fedora 28 | ❌  |
## Features
* MySQL 5.7
* PHP 7.2
* phpMyAdmin 4.8.5
## To-Do
* Choix de la version MineWeb & PHP
* ~~phpMyAdmin à la dernière version~~
* Php 7.3, puisqu'il est supporté depuis [#5](https://github.com/MineWeb/MineWebCMS/pull/5/),  [#100](https://github.com/MineWeb/MineWebCMS/pull/100/) ---> phpMyAdmin ne le supporte pas encore officiellement.
* Possibilité de choisir nginx au lieu de apache2
* Let's Encrypt
* mysql_secure_installation (automatique)
* ~~Supporté Debian 8, Ubuntu 16.04 & 18.04~~
## FAQ
**MERCI DE REGARDER LE [WIKI](https://github.com/fightmaxime/mineweb-install/wiki/FAQ)**
