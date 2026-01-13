
?? Objectif du Chapitre 1
Apprendre Terraform sans cloud, en local, avec Docker comme infrastructure cible.

On a voulu comprendre:

comment Terraform décrit une infra

comment il garde l’état (state)

comment il crée, modifie, détruit

comment il détecte les écarts (drift)

?? Infrastructure créée

1 réseau Docker

1 base PostgreSQL

1 Adminer (UI DB)

1 Nginx (web simple)

?? Structure finale du dossier
docker/00-basics/
+-- versions.tf
+-- variables.tf
+-- main.tf
+-- outputs.tf
+-- terraform.tfvars
+-- .terraform/
+-- .terraform.lock.hcl


Chaque fichier a un rôle précis.

?? Détail fichier par fichier
1?? versions.tf
Rôle

Définir:

la version minimale de Terraform

les providers nécessaires (ici Docker)

Contenu
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

Pourquoi c’est important

Terraform sait quel provider installer

Tu évites les surprises de version

Reproductible sur n’importe quelle machine

?? Sans ce fichier, Terraform ne sait même pas comment parler à Docker.

2?? variables.tf
Rôle

Déclarer ce qui peut varier:

ports

credentials

noms logiques

Contenu clé
variable "postgres_password" {
  type      = string
  sensitive = true
}

Pourquoi c’est important

Tu ne hardcodes pas les valeurs sensibles

Terraform masque le mot de passe dans les logs

Tu peux changer la config sans toucher au code

?? Principe DevOps: séparer le code de la configuration.

3?? terraform.tfvars
Rôle

Fournir les valeurs réelles aux variables.

postgres_password = "admin"
postgres_port     = 55432

Pourquoi c’est important

Terraform lit automatiquement ce fichier

Tu évites les prompts interactifs

Tu peux avoir plusieurs .tfvars (dev, test, prod)

?? En CI/CD, ce fichier est souvent remplacé par des variables d’environnement.

4?? main.tf
Rôle

Décrire l’infrastructure réelle.

Ce qu’on a créé
?? Réseau Docker
resource "docker_network" "lab" {
  name = "tf-lab-net"
}


?? But:

isoler les conteneurs

permettre la résolution DNS (tf-postgres)

?? Image + conteneur PostgreSQL
resource "docker_image" "postgres" {
  name = "postgres:16-alpine"
}

resource "docker_container" "postgres" {
  name  = "tf-postgres"
  image = docker_image.postgres.image_id
}


?? But:

image = artefact

container = instance qui tourne

ports = mapping host ? container

?? Important:

Postgres écoute sur 5432 dans le container

exposé sur 55432 côté host

?? Adminer

UI web pour se connecter à PostgreSQL.

?? Pourquoi c’est pédagogique:

tu vois que les conteneurs communiquent via le réseau Docker

dans Adminer, le serveur = tf-postgres, pas localhost

?? Nginx

Simple service web pour illustrer:

un service stateless

une exposition HTTP

5?? outputs.tf
Rôle

Afficher des infos utiles après apply.

output "adminer_url" {
  value = "http://localhost:8081"
}

Pourquoi c’est important

Terraform n’est pas qu’un outil de création

il peut documenter ce qu’il a créé

très utile en CI/CD pour passer des infos à l’étape suivante

6?? .terraform/ et .terraform.lock.hcl
Rôle

.terraform/ ? providers téléchargés

.terraform.lock.hcl ? versions exactes utilisées

?? À ne jamais modifier à la main
?? À committer dans Git (lock), comme un package-lock.json.

?? Commandes Terraform (et leur but)
terraform init

?? Initialise le projet:

télécharge le provider Docker

prépare le backend (state local ici)

Sans init ? rien ne marche.

terraform plan

?? Simule:

ce que Terraform va faire

sans rien créer

Tu as vu:

Plan: 7 to add, 0 to change, 0 to destroy.


?? Très important en prod: jamais d’apply sans plan.

terraform apply

?? Exécute réellement:

création du réseau

pull des images

démarrage des conteneurs

Terraform agit dans l’ordre logique grâce au graphe de dépendances.

terraform destroy

?? Détruit tout ce que Terraform a créé.

sans toucher au reste de Docker

propre, traçable

?? Concept clé appris: le STATE

Terraform garde un fichier:

terraform.tfstate


Il contient:

ce qui existe

avec quels IDs Docker

dans quel état

?? Terraform ne “scanne” pas Docker
?? Il compare le state avec le code.

?? Concept clé appris: DRIFT

Quand tu as fait:

docker rename tf-web tf-web-hacked


?? Docker a changé
?? Terraform n’était pas au courant

Puis:

terraform plan


Terraform a dit:

“Ce que j’ai dans le state ? la réalité”

?? C’est exactement comme en prod quand quelqu’un “bricole” un serveur à la main.