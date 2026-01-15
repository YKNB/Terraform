# 📦 Terraform Local Lab – Chapitre 1  
### Apprendre Terraform **sans cloud**, en local, avec **Docker** comme infrastructure cible

---

## 🎯 Objectif du Chapitre 1

L’objectif de ce chapitre est d’apprendre **Terraform en profondeur**, sans dépendre d’un fournisseur cloud.

Toute l’infrastructure est déployée **en local**, avec **Docker** comme cible, afin de se concentrer sur les **fondamentaux Terraform**.

Ce laboratoire permet de comprendre :

- comment Terraform **décrit une infrastructure**
- comment il **stocke et exploite l’état (state)**
- comment il **crée, modifie et détruit** des ressources
- comment il **détecte les écarts (drift)** entre le code et la réalité

> 💡 Avant AWS, Azure ou GCP, on maîtrise d’abord la mécanique interne de Terraform.

---

## 🧱 Infrastructure créée

Terraform déploie automatiquement :

- 🛜 **1 réseau Docker**
- 🐘 **1 conteneur PostgreSQL**
- 🧑‍💻 **1 Adminer** (UI de gestion de base de données)
- 🌐 **1 Nginx** (service web simple)

Tous les services communiquent via **un réseau Docker géré par Terraform**.

---

## 📁 Structure finale du projet

```bash
docker/00-basics/
├── versions.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars
├── .terraform/
└── .terraform.lock.hcl
```

Chaque fichier a un rôle précis et suit les **bonnes pratiques Terraform**.

---

## 🧩 Détail fichier par fichier

---

### 1️⃣ `versions.tf`

#### 🎯 Rôle

- Définir la version minimale de Terraform
- Déclarer les providers nécessaires (Docker)

#### 📄 Contenu

```hcl
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
```

#### ✅ Pourquoi c’est important

- Terraform sait **quel provider installer**
- Les versions sont contrôlées
- Le projet est **reproductible sur n’importe quelle machine**

> ❌ Sans ce fichier, Terraform ne sait même pas comment communiquer avec Docker.

---

### 2️⃣ `variables.tf`

#### 🎯 Rôle

Déclarer tout ce qui peut varier :

- ports
- identifiants
- paramètres sensibles

#### 📄 Exemple

```hcl
variable "postgres_password" {
  type      = string
  sensitive = true
}
```

#### ✅ Pourquoi c’est important

- Aucun secret en dur dans le code
- Les valeurs sensibles sont masquées dans les logs
- La configuration est découplée de l’infrastructure

> 📌 Principe DevOps : **séparer le code de la configuration**

---

### 3️⃣ `terraform.tfvars`

#### 🎯 Rôle

Fournir les **valeurs réelles** aux variables.

#### 📄 Exemple

```hcl
postgres_password = "admin"
postgres_port     = 55432
```

#### ✅ Pourquoi c’est important

- Chargé automatiquement par Terraform
- Évite les prompts interactifs
- Permet plusieurs environnements (`dev`, `test`, `prod`)

> 📌 En CI/CD, ces valeurs sont souvent injectées via des variables d’environnement.

---

### 4️⃣ `main.tf`

#### 🎯 Rôle

Décrire l’infrastructure réelle.

---

#### 🛜 Réseau Docker

```hcl
resource "docker_network" "lab" {
  name = "tf-lab-net"
}
```

**But :**
- Isoler les conteneurs
- Permettre la résolution DNS interne (`tf-postgres`)

---

#### 🐘 Image et conteneur PostgreSQL

```hcl
resource "docker_image" "postgres" {
  name = "postgres:16-alpine"
}

resource "docker_container" "postgres" {
  name  = "tf-postgres"
  image = docker_image.postgres.image_id
}
```

**Concept clé :**
- `docker_image` = artefact
- `docker_container` = instance en cours d’exécution

📌 PostgreSQL :
- écoute sur **5432** dans le conteneur
- exposé sur **55432** côté host

---

#### 🧑‍💻 Adminer

Adminer est une **interface web** pour gérer PostgreSQL.

Point pédagogique clé :
- Les conteneurs communiquent via le réseau Docker
- Dans Adminer, le serveur est `tf-postgres`, pas `localhost`

---

#### 🌐 Nginx

Service web simple permettant d’illustrer :

- un service **stateless**
- une exposition HTTP
- un composant indépendant de la base de données

---

### 5️⃣ `outputs.tf`

#### 🎯 Rôle

Afficher des informations utiles après le déploiement.

```hcl
output "adminer_url" {
  value = "http://localhost:8081"
}
```

#### ✅ Pourquoi c’est important

- Terraform ne fait pas que créer des ressources
- Il peut aussi **documenter ce qu’il déploie**
- Très utile pour enchaîner des étapes en CI/CD

---

### 6️⃣ `.terraform/` et `.terraform.lock.hcl`

#### 🎯 Rôle

- `.terraform/` : providers téléchargés
- `.terraform.lock.hcl` : versions exactes utilisées

⚠️ Bonnes pratiques :
- Ne jamais modifier ces fichiers à la main
- Le fichier `lock` doit être **committé dans Git**

> Comparable à un `package-lock.json` ou `poetry.lock`.

---

## ⚙️ Commandes Terraform utilisées

---

### `terraform init`

Initialise le projet :

- télécharge le provider Docker
- prépare le backend (state local)

> ❌ Sans `init`, Terraform ne fonctionne pas.

---

### `terraform plan`

Simule les actions à venir :

```text
Plan: 7 to add, 0 to change, 0 to destroy
```

- Aucun changement réel
- Visualisation claire de l’impact

> 📌 En production : **jamais d’apply sans plan**

---

### `terraform apply`

Exécute réellement :

- création du réseau
- récupération des images
- démarrage des conteneurs

Terraform respecte l’ordre grâce au **graphe de dépendances**.

---

### `terraform destroy`

Supprime uniquement ce que Terraform a créé :

- sans impacter le reste de Docker
- de manière propre et traçable

---

## 🧠 Concept clé : le STATE

Terraform maintient un fichier :

```text
terraform.tfstate
```

Il contient :

- les ressources existantes
- leurs identifiants Docker
- l’état exact de l’infrastructure

> 📌 Terraform ne scanne pas Docker  
> 👉 Il compare **le code** avec **le state**

---

## ⚠️ Concept clé : le DRIFT

Exemple :

```bash
docker rename tf-web tf-web-hacked
```

- Docker a changé
- Terraform n’est pas au courant

Puis :

```bash
terraform plan
```

Terraform détecte un **écart entre le state et la réalité**.

> 📌 Exactement ce qui se passe en production quand quelqu’un modifie une infra à la main.

---

## ✅ Conclusion

Ce chapitre permet de :

- comprendre Terraform sans cloud
- maîtriser le state et le cycle de vie
- poser des bases solides avant les modules et le cloud

➡️ Prochaine étape :  
**Chapitre 2 – Terraform avec Modules (approche professionnelle)** 🚀