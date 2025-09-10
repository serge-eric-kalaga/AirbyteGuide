# Airbyte - Guide d'implémentation

## Présentation
Ce projet met en place une synchronisation de données entre deux bases PostgreSQL (source et destination) à l'aide d'Airbyte, avec un exemple de base de données de gestion de tâches (utilisateur, tache).

## Prérequis
- Docker et Docker Compose installés
- Accès à un terminal bash

## Structure du projet
- `docker-compose.yaml` : Configuration des services Docker (Postgres source/destination)
- `init-mysql-src.sql` : Script d'initialisation de la base source (tables, données)
- `init-mysql-des.sql` : Script d'initialisation de la base destination (optionnel)
- `postgres/` : Dossier pour d'autres scripts SQL

## Démarrage rapide

1. **Lancer les conteneurs**
   ```bash
   docker compose up -d
   ```

2. **Vérifier que les bases sont accessibles**
   - Source : `localhost:5432` (utilisateur : airbyte, mot de passe : airbyte, base : tasks_list)
   - Destination : `localhost:5433` (mêmes identifiants)

3. **Initialiser la base source**
   - Le script `init-mysql-src.sql` est exécuté automatiquement à la création du conteneur.

> **Remarque importante :**
> Il est nécessaire d'activer l'extension vector dans les deux bases de données (source et destination) avec la commande suivante :
> ```sql
> CREATE EXTENSION IF NOT EXISTS vector;
> ```
>
> Il faut également installer le paquet de vectorisation correspondant à la version de PostgreSQL utilisée. Par exemple, pour PostgreSQL 17 :
> ```bash
> apt-get update && apt-get install -y \
>     postgresql-17-pgvector \
>     && rm -rf /var/lib/apt/lists/*
> ```
> Adaptez le nom du paquet (`postgresql-<version>-pgvector`) à la version de PostgreSQL installée.

## Installation d'Airbyte

Pour installer Airbyte OSS, suivez le guide officiel :  
https://docs.airbyte.com/platform/using-airbyte/getting-started/oss-quickstart

## Configuration de la réplication logique (pour Airbyte)

1. **Préremplir la configuration source Postgres**
2. **Accorder les droits de réplication à l'utilisateur**
   ```sql
   ALTER USER airbyte REPLICATION;
   ```
3. **Activer la réplication logique**
   (à ajouter dans la configuration Postgres ou via la commande Docker)
   ```bash
   postgres -c wal_level=logical \
           -c max_replication_slots=10 \
           -c max_wal_senders=10
   ```
4. **Créer un slot de réplication**
   ```sql
   SELECT pg_create_logical_replication_slot('airbyte_slot', 'pgoutput');
   ```
5. **Définir l'identité de réplication sur chaque table**
   > Le script ci-dessous applique l'identité de réplication à toutes les tables du schéma public. Vous pouvez le modifier pour ne cibler que certaines tables à répliquer si besoin.
   ```sql
   DO $$
   DECLARE
       r RECORD;
   BEGIN
       FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'public'
       LOOP
           EXECUTE format('ALTER TABLE public.%I REPLICA IDENTITY DEFAULT;', r.tablename);
       END LOOP;
   END $$;
   ```
6. **Créer la publication**
   > La commande suivante crée une publication pour toutes les tables. Vous pouvez la restreindre à une liste de tables spécifiques si vous ne souhaitez répliquer qu'une partie du schéma :
   ```sql
   CREATE PUBLICATION airbyte_publication FOR ALL TABLES;
   -- ou pour des tables précises :
   -- CREATE PUBLICATION airbyte_publication FOR TABLE utilisateur, tache;
   ```

## Exemple de tables

- Table `utilisateur` : id, username, email
- Table `tache` : id, title, description, due_date, is_completed, utilisateur_id

## Ressources
- Guide d'installation Airbyte OSS : https://docs.airbyte.com/platform/using-airbyte/getting-started/oss-quickstart
- Documentation Airbyte : https://docs.airbyte.com/
- Documentation Postgres : https://www.postgresql.org/docs/

