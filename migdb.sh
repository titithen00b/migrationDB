#!/bin/env bash

# configuration de l'utilisateur MySQL et de son mot de passe
DB_USER_SOURCE=
DB_PASS_SOURCE=
DB_USER_CIBLE=
DB_PASS_CIBLE=

# configuration de la machine hébergeant le serveur MySQL
DB_HOST_=

# Declaration serveur source
HOST=

# Declaration serveur cible
HOST_CIBLE=
USER_SSH_CIBLE=

# Décommenter PASSWORD_SSH si connexion par mdp
#PASSWORD_SSH=

# declaration de la base distante
DB_CIBLE=

# sous-chemin de destination
OUTDIR=`date +%Y-%m-%d`
# création de l'arborescence
sudo mkdir -p /tmp/$OUTDIR
sudo chmod -R 777 /tmp/$OUTDIR

# récupération de la liste des bases
DATABASES=`MYSQL_PWD=$DB_PASS_SOURCE mysql -u $DB_USER_SOURCE -e "SHOW DATABASES;" | tr -d "| " | grep -v -e Database -e _schema -e mysql`
# boucle sur les bases pour les dumper
for DB_NAME in $DATABASES; do
    MYSQL_PWD=$DB_PASS mysqldump -u $DB_USER --single-transaction --skip-lock-tables $DB_NAME -h $DB_HOST > /tmp/$OUTDIR/$DB_NAME.sql
done

# Copie des fichiers sur le serveur cible
scp /tmp/$OUTDIR/ebdb.sql $USER_SSH_CIBLE@$HOST_CIBLE:/tmp/ebdb.sql

# Installation de la nouvelle base sur l'ancienne
ssh $USER_SSH_CIBLE@$HOST_CIBLE 'sudo mysql -u$DB_USER_CIBLE -p$DB_PASS_CIBLE -h localhost ebdb < /tmp/ebdb.sql && sudo rm -rf /tmp/ebdb.sql'

#Supression de la base exporter
rm -rf /tmp/$OUTDIR
