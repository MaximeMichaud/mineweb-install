# Installation de MineWeb sur un VPS
Bonjour, voici un court tutoriel sur *comment installer MineWeb sur un VPS*.
# Mineweb, c'est quoi ?
C'est un CMS (Content Management System), c'est à dire un système qui va vous permettre de gérer votre site web orienté Minecraft sans une lige de code.
Voir le site : [mineweb.org
](http://mineweb.org)
# VPS
Vous aurez besoin d'un VPS. On peut en trouver [chez OVH](https://www.ovh.com/fr/), [chez MTXServ](https://mtxserv.com/) ou encore [chez InovaPerf](https://inovaperf.fr/) par exemple.
On vous aura donné des identifiants.
Procédons à l'installation !!
# Installation
Vous aurez besoin [de télécharger Putty](https://putty.org/) si vous êtes sur Windows.
## Connexion SSH sur Windows
Démarrez Putty. Vous aurez la fenêtre suivante :
![Fenêtre de Putty](https://img.hynity.com/images/2019/04/05/putty_yKwo3sDJoD.png)
Entrez dans 

> Host Name (or IP Adress)

l'adresse IP de votre VPS.
Cela me donne ce résultat :
![IP adress](https://img.hynity.com/images/2019/04/05/putty_SohHOKiwZ8.png)
Cliquez ensuite sur "Open" au bas de la fenêtre.
Une fenêtre de sécurité s'ouvrira alors, vous avez juste à cliquer sur "Oui" en bas.
## Connexion SSH sous Mac ou Linux
Pour se connecter en SSH avec un Mac ou avec Linux il suffit d'ouvrir le terminal et de taper : 

    ssh <utilisateur>@<ip>
   En remplaçant les données type par les vôtres.
## Suite
Vous obtiendrez ceci:
![putty1](https://img.hynity.com/images/2019/04/05/putty_O45y47CoDS.png)
Rentrez votre nom d'utilisateur dans "Login as" (la plupart du temps l'utilisateur est "root") puis mettez le mot de passe (ils ne s'affichent pas sous UNIX donc pas d'inquiétude). 

   

> Note : Pour coller du texte sous Putty, il faut faire clique-droit

Vous arriverez sur :
![putty2
](https://img.hynity.com/images/2019/04/05/putty_pOmhur6I5o.png)
Tapez la commande (ou copiez/collez) :

    wget https://raw.githubusercontent.com/fightmaxime/mineweb-install/master/mineweb-install.sh
Si vous obtenez quelque chose comme ça, alors vous êtes bons :
![
](https://img.hynity.com/images/2019/04/05/putty_a4OF7rmpVa.png)
On tape ensuite les deux commandes suivantes :

    chmod +x mineweb-install.sh
    ./mineweb-install.sh
On nous pose des question, laissez celles par défaut et appuyez sur entrée :
![enter image description here](https://img.hynity.com/images/2019/04/05/chrome_T2QKMvpfsx.png)
![enter image description here](https://img.hynity.com/images/2019/04/05/putty_ALEwnB2xD4.png)
Enfin, appuyez sur n'importe quelle touche (ex: entrée) pour terminer l'installation :
![enter image description here](https://img.hynity.com/images/2019/04/05/putty_d9hZcrQB30.png)
Laissez le script faire son travail...
Descendez jusqu'à "OK" puis appuyez sur entrée lorsqu'on vous pose cette question :
![
](https://img.hynity.com/images/2019/04/05/putty_AdyXEYNsda.png)
Allez ensuite sur le site [motdepasse.xyz](https://www.motdepasse.xyz) pour générer un mot de passe :
![
](https://img.hynity.com/images/2019/04/05/chrome_uY4rStWw8j.png)
Cliquez sur "Créer votre mot de passe". **NOTEZ LE BIEN** !! Copiez le mot de passe qui s'affiche à l'écran et collez le sur le champ qui s'affiche en SSH :
![enter image description here](https://img.hynity.com/images/2019/04/05/putty_98jFv12Bg4.png)
Appuyez sur entrée.
Confirmez-le une seconde fois :
![enter image description here](https://img.hynity.com/images/2019/04/05/putty_on9E68ExK4.png)
Appuyez ensuite sur votre touche entrée pour confirmer.
Appuyez également sur entrée pour confirmer le choix prédéfini pour phpMyAdmin :
![
](https://img.hynity.com/images/2019/04/05/putty_UC1QE1xD7g.png)
De même ici :
![
](https://img.hynity.com/images/2019/04/05/putty_ydD77uMARs.png)
Retournez sur le générateur de mots de passe et générez un nouveau mot de passe que vous collez ici :
![
](https://img.hynity.com/images/2019/04/05/putty_7qn1xQw5AC.png)
Confirmez-le :
![
](https://img.hynity.com/images/2019/04/05/putty_0XkiduwMIZ.png)
Renseignez ensuite le mot de passe de l'administrateur (user "root" mysql).
Quand vous voyez ceci, l'installation est terminée.
![enter image description here](https://img.hynity.com/images/2019/04/05/putty_XaiirfG3XB.png)
Pour vérifier si l'installation a marché, rendez vous sur l'IP de votre VPS. Si vous voyez la page d'installation de MineWeb, alors le tour est joué :
![enter image description here](https://img.hynity.com/images/2019/04/05/chrome_DfnqpVZDs7.png)
Ensuite, allez sur phpmyadmin : [http://ip.fr/phpmyadmin
](http://site.fr/phpmyadmin)
Connectez vous avec l'utilisateur "root" et le mot de passe défini plus tôt, cliquez sur exécuter puis sur "Nouvelle base de données" :
![
](https://img.hynity.com/images/2019/04/05/chrome_SsjhRFaOV3.png) 
Nommez là "MineWeb" puis cliquez sur "Créer" : 
![
](https://img.hynity.com/images/2019/04/05/chrome_kNpKGp8NiY.png)
Quittez la page et revenez sur la page d'installation (IP dans le navigateur). Remplissez les champs :

    Adresse de la base de données : localhost
    Nom de la base de données : mineweb
    Nom d'utilisateur : root
    Mot de passe: <mot de passe défini plus haut pour mysql>
   Cliquez sur "Tester et enregistrer' puis sur "Installer la base de données" :
   ![
](https://img.hynity.com/images/2019/04/05/chrome_4p4LYo5rLJ.png)

Remplissez les champs pour configurer votre compte administrateur et cliquez sur "suivant", et enfin sur "Passer à l'utilisation" :
![
](https://img.hynity.com/images/2019/04/05/chrome_RXfGEfYqS7.png)
Voilà, c'est installé :
![
](https://img.hynity.com/images/2019/04/05/chrome_UkWyHDasfE.png)

Par :

    DarkScientist_#9449
[Rejoindre le discord de MineWeb](https://discordapp.com/invite/3QYdt8r)
