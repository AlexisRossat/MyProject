## Install de zéro /!\ Non recommandé /!\
### => Passez directement au chapitre suivant

Install de docker-compose : 

```console
sudo apt install composer
```

Création du projet symfony :

```console
composer create-project symfony/website-skeleton MyProject
```

Configuration : 
 - copier le répertoire docker dans MyProject/
 - copier le makefile et le docker-compose.yml dans MyProject/
 - copier ou écrire le .env.local

## Install à partir de l'archive 

### Méthode 1 (recommandée)

Clonez le dépôt depuis GitHub (en SSH) :

```console
cd ~
mkdir Projects
git clone git@github.com:AlexisRossat/MyProject.git
```

Puis passez à l'étape de **Configuration du projet**.

### Méthode 2 (non recommandée)

Téléchargez l'archive dans votre dossier personnel (`/home/{user}`) puis décompressez l'archive dans un nouveau dossier "Projects" : 

```console
cd ~
mkdir Projects 
cd Projects
tar zxvf MyProject.tar.gz
```

### Configuration du projet 
Le projet doit se trouver dans `/home/{user}/Projects/MyProject`.

Créez le dossier "mysql-data-dir" dans le répertoire "Projects" :

```console
cd ~/Projects
mkdir mysql-data-dir
```

Le volume pour la base de données doit donc se trouver dans `/home/{user}/Projects/mysql-data-dir`.

Maintenant, installez `make`, `docker` et `docker-compose` :

```console
sudo apt install make docker docker-compose
```

Dans le Dockerfile (`/home/user/Projects/MyProject/docker/web/Dockerfile`), modifiez la dernière ligne en indiquant votre nom d'utilisateur (3 occurrences) :

```console
id user # Remplacez user par votre nom d'utilisateur
```

Paramétrez le chemin vers la base de données en modifiant le fichier `docker-compose.yml` :

```console
/home/{user}/Projects/mysql-data-dir:/var/lib/mysql
```

Démarrez le projet :

```console
make start
```

## Voilà, ça marche !

Pour accéder à PhpMyAdmin : 
 - Url : "http://localhost:8080/"
 - Login: "root"
 - Password : "" (aucun)

Pour accéder au projet (web)
 - Url : "http://localhost:8000/"
