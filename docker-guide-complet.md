# Docker - Guide complet

## 1. Utilisation

### Le conteneur

Un **conteneur**, c'est une boite qui contient l'environnement d'exécution d'une **image** :

- un environnement d'OS
- système de fichier virtuel
- port de communication

Il se définit par :

- son image (nom et version précise)
- un nom de conteneur (donné aléatoirement par défaut)
- un ID de conteneur
- des variables d'environnement (nom de base, identifiant de connexion administrateur, etc.)
- des ports de communications
- des volumes qui vont contenir les données

### De la pratique

#### Lister ce que Docker connait

Lister les conteneurs en cours d'éxécution

```bash
docker ps
docker ps -a
```

`-a` liste aussi les conteneurs arrêtés

Lister les images disponibles

```bash
docker images
```

#### Lancer et gérer nos conteneurs

##### RUN

Créer et lancer un conteneur depuis une image :

```bash
docker run <image>
docker run -d <image>
docker run -p <local port>:<container port>
docker run --name <container names> <image>
```

Si l'image n'est pas en local, docker essaie de la télécharger.

`-d` permet de détacher l'exécution du conteneur de l'utilitaire de ligne de commande.

`-p` permet de lier un port local à celui du conteneur

`--name` permet de définir manuellement le nom du conteneur

##### STOP

Arrêter un conteneur

```bash
docker stop <CONTAINER ID>
```

##### START

Relancer un contenteur

```bash
docker start <CONTAINER ID>
```

##### RM

Supprimer un conteneur

```bash
docker rm <CONTAINER ID>
```

#### Gérer nos images

##### RMI

Supprimer une image de docker

```bash
docker rmi <IMAGE ID>
```

##### pull

Télécharge l'image, mais ne la charge pas dans un conteneur

```bash
docker image pull <image>
docker pull <image>
```

##### save

Enregistre localement une image

```bash
docker save -o <path/file>.tar <CONTAINER ID>
```

##### load

Charge une image local dans docker

```bash
docker load -i <path/file>.tar
```

### La machine dans la machine

> Docker va se comporter comme une machine à part entière, à l'intérieur même de votre système. Ainsi, les différents conteneurs en cours d'exécution communiquent avec l'extérieur -votre système- via des **ports**.

Vous allez donc devoir connecter les ports de votre machine à ceux des conteneurs docker. Rassurez-vous, cette configuration est, la plupart du temps, automatique. Ainsi, si un conteneur écoute le port 5000 du système Docker, il sera relié au port 5000 de votre machine.

#### Si plusieurs conteneurs écoutent le même port ?

- [ ] Couper l'exécution des conteneurs en faute
- [ ] Relancer le conteneur en reliant le port par défaut à un autre port de la machine
    - Exemple : `docker run -p 3306:3307 mysql`

---

<!-- Partie 3  -->

## Développement

### Accéder au conteneur

On a lancé notre conteneur, mais à cause de son environnement isolé, nous n'y avons pas accès.

#### Les logs

Pour vérifier qu'un conteneur fonctionne bien, on va pouvoir vérifier ses logs.

```bash
docker logs <CONTAINER ID / CONTAINER NAMES>
```

#### L'accès exec

Un conteneur est un environnement linux. Nous allons pouvoir y entrer pour l'utiliser directement de l'intérieur.

```bash
docker exec -it <CONTAINER ID / CONTAINER NAMES> /bin/bash
```

> On lui précise ici qu'on utilise l'environnement `bin/bash`. S'il n'est pas disponible, on peut utiliser l'environnement `/bin/sh`.

> C'est un environnement classique linux, vous pouvez donc l'explorer en ligne de commande.

Vous pouvez quitter l'intérieur de votre conteneur via la commande `exit`.

> Si vous avez un doute sur les variables d'environnement de votre conteneur, vous pouvez les consulter avec la commande `env`.

### Accéder à une base de données dans un conteneur

Une base de données est un environnement qui nécessite lui-même une connexion.

#### Depuis exec

Une fois à l'intérieur de notre conteneur via `docker exec` :

##### PostgreSQL

Nous allons nous connecter à la base depuis l'intérieur du conteneur :

```bash
psql -U <USER> -d <DataBase>
```

| commande | action |
|--------|------|
| `\dt` | liste les tables disponibles |
| `\d <table>` | décrit la structure d'une table |
| `\l` | liste les bases de données |
| `\q` ou `quit` | quitte la base |

##### MySQL

```bash
mysql -u <user> -p <database>
```

Le mot de passe de la base sera à saisir ensuite.

| commande | action |
| ---------- | -------- |
| `SHOW TABLES;` | liste les tables disponibles |
| `DESCRIBE <table>;` | décrit la structure d'une table |
| `SHOW DATABASES;` | liste les bases de données |
| `EXIT;` ou `\q` | quitte la base |

##### SQLite

```bash
sqlite3 /<path>/<database>.db
```

| commande | action |
| ---------- | -------- |
| `.tables` | liste les tables disponibles |
| `.schema <table>` | décrit la structure d'une table |
| `.databases` | liste les bases attachées |
| `.quit` ou `.exit` | quitte la base |

#### Sans passer par exec

On peut aussi appeler la base de données sans avoir à passer par l'intérieur de notre conteneur.

##### Avec un client de base de données

Si vous possédez un client d'un sgbd sur votre machine, ou un système capable de s'y interfacer, vous pouvez vous y connecter directement.

###### PostgreSQL

```bash
psql -h <host> -p <port> -U <user> -d <database>
```

Ou via une URL de connexion complète :

```bash
psql postgresql://<user>:<password>@<host>:<port>/<database>
```

###### MySQL

```bash
mysql -h <host> -P <port> -u <user> -p<password> <database>
```

##### Sans client, via exec en une seule ligne

On peut aussi passer par le client interne du conteneur, en une seule commande `docker exec`.

###### PostgreSQL

```bash
docker exec -it <container> psql -U <user> -d <database>
```

> Si on utilise un fichier sql pour contenir l'ensemble de nos requêtes, il est possible de simplement rediriger celui-ci. Ex : `docker exec -i <container> psql -U <user> -d <database> < mes_requetes.sql`

###### MySQL

```bash
docker exec -it <container> mysql -u <user> -p<password> <database>
```

###### SQLite

```bash
docker exec -it <container> sqlite3 /chemin/vers/<database>.db
```

---

<!-- Partie 4  -->

## Compose

On sait lancer un conteneur unique et lui fournir toutes les informations dont il a besoin, mais tout faire à chaque fois, c'est long et pas très pratique.

Exemple :

```bash
docker run -d \
    --name mongodb \
    -p 27017:27017 \
    -e MONGO-INITDB_ROOT_USERNAME=admin \
    -e MONGO-INITDB_ROOT_PASSWORD=password \
    --net mongo-network \
    mongo
docker run -d \
    --name mongo-express \
    -p 8080:8080 \
    -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin \
    -e ME_CONFIG_MONGODB_ADMINPASSWORD=password \
    -e ME_CONFIG_MONGODB_SERVER=mongodb \
    --net mongo-network \
    mongo-express
```

### docker-compose.yml

Pour éviter ça, on préfère écrire l'ensemble de la configuration dans un fichier **docker-compose.yml**. Docker se chargera ensuite de tout mettre en place, partie réseaux comprise.

Exemple :

```yaml
services:
    mongodb:
        image: mongo
        ports:
            - 27017:27017
        environment:
            - MONGO-INITDB_ROOT_USERNAME=admin
            - MONGO-INITDB_ROOT_PASSWORD=password
    mongo-express:
        image: mongo-express
        ports:
            - 8080:8080
        environment:
            - ME_CONFIG_MONGODB_ADMINUSERNAME=admin
            - ME_CONFIG_MONGODB_ADMINPASSWORD=password
            - ME_CONFIG_MONGODB_SERVER=mongodb
```

#### Les données

Dans un fichier yaml de compose, vous devez préciser :

- le nom du conteneur (ici mongodb)
- l'image exacte (ici mongo)
- le nom d'utilisation du conteneur (via une ligne `container_name`)
- les variables d'environnement
- les ports
- les volumes

Attention, les volumes devront être rappelés à la fin du fichier, pour indiquer à docker comment les mettre en place.

```yaml
<...>
    volumes:
      - adakor-data:/var/lib/postgresql/data

volumes:
  adakor-data:
```

### Utilisation

C'est là que ça prend tout son sens :

```bash
docker compose up -d
```

Et pour l'arrêter ?

```bash
docker compose down
```
