# 📦 Terraform Local Lab – Chapitre 2  
### Terraform avec **Modules** – Approche professionnelle

---

## 🎯 Objectif du Chapitre 2

Ce chapitre marque un **changement de niveau** : on passe d’un Terraform monolithique à une **architecture modulaire**, proche de ce qui est attendu en **entreprise / production**.

Après avoir compris :
- le fonctionnement de Terraform
- le state
- le cycle de vie des ressources

👉 l’objectif ici est d’apprendre à **structurer, factoriser et réutiliser** le code Terraform.

---

## 🧠 Pourquoi utiliser des modules Terraform ?

Sans modules, un projet Terraform devient rapidement :
- difficile à lire
- difficile à maintenir
- impossible à réutiliser

Les **modules** permettent de :

- découper l’infrastructure par **responsabilité**
- réutiliser le même code pour plusieurs environnements
- standardiser les déploiements
- faciliter le travail en équipe

> 📌 Un module Terraform est l’équivalent d’une **fonction** ou d’un **composant réutilisable**.

---

## 🧱 Infrastructure cible (inchangée fonctionnellement)

Fonctionnellement, l’infrastructure reste la même que dans le chapitre 1 :

- 🛜 réseau Docker
- 🐘 PostgreSQL
- 🧑‍💻 Adminer
- 🌐 Nginx

La différence majeure est **l’organisation du code**, pas le résultat.

---

## 📁 Nouvelle structure du projet (modulaire)

```bash
docker/01-modules/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── versions.tf
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── postgres/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── adminer/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── nginx/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── .terraform/
└── .terraform.lock.hcl
```

👉 Chaque module correspond à **un composant métier clair**.

---

## 🧩 Principe de fonctionnement des modules

- Le **root module** (racine) orchestre l’infrastructure
- Les **modules enfants** créent les ressources
- Les variables sont passées **du root vers les modules**
- Les outputs remontent **des modules vers le root**

```text
Root Module
   ├── module.network
   ├── module.postgres
   ├── module.adminer
   └── module.nginx
```

---

## 📄 Root Module – fichiers principaux

### `versions.tf`

Même rôle que dans le chapitre 1 :
- version Terraform
- provider Docker

Le provider est déclaré **une seule fois**, au niveau racine.

---

### `main.tf`

Le fichier `main.tf` du root module **n’instancie plus directement de ressources**.

Il appelle des modules :

```hcl
module "network" {
  source = "./modules/network"
  network_name = "tf-lab-net"
}

module "postgres" {
  source = "./modules/postgres"
  network_name = module.network.name
}
```

📌 Le root module :
- orchestre
- connecte les briques
- ne connaît pas les détails internes

---

### `variables.tf`

Contient uniquement les variables **globales** :
- ports
- credentials
- noms logiques

👉 Pas de logique métier ici.

---

### `terraform.tfvars`

Fournit les valeurs concrètes :

```hcl
postgres_password = "admin"
postgres_port     = 55432
```

---

### `outputs.tf`

Centralise les outputs utiles :

- URL Adminer
- ports exposés

Ces outputs peuvent être consommés :
- par un humain
- par un pipeline CI/CD

---

## 🧱 Détail des modules

---

### 📦 Module `network`

#### Responsabilité

Créer **uniquement** le réseau Docker.

#### Contenu

- `docker_network`
- output : nom du réseau

📌 Ce module est :
- simple
- réutilisable
- indépendant

---

### 🐘 Module `postgres`

#### Responsabilité

- image PostgreSQL
- conteneur PostgreSQL
- exposition des ports

#### Entrées

- nom du réseau
- mot de passe
- port

#### Sorties

- nom du conteneur
- port exposé

---

### 🧑‍💻 Module `adminer`

#### Responsabilité

- image Adminer
- conteneur Adminer
- connexion au réseau Docker

📌 Point pédagogique :
- Adminer se connecte à PostgreSQL via le **DNS Docker**

---

### 🌐 Module `nginx`

#### Responsabilité

- service web stateless
- exposition HTTP

Ce module illustre :
- un composant sans état
- facilement duplicable

---

## 🔁 Flux des variables et outputs

```text
terraform.tfvars
   ↓
root variables.tf
   ↓
modules/*/variables.tf
   ↓
resources
   ↑
modules/*/outputs.tf
   ↑
root outputs.tf
```

👉 Flux **clair, lisible et maîtrisé**.

---

## ⚙️ Commandes Terraform (identiques)

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

💡 Différence majeure :
- Terraform affiche désormais les **modules** dans le plan
- La lecture du plan est beaucoup plus claire

---

## 🧠 Ce qui change par rapport au Chapitre 1

| Chapitre 1 | Chapitre 2 |
|----------|-----------|
| Code plat | Code modulaire |
| Peu réutilisable | Hautement réutilisable |
| Pédagogique | Professionnel |
| Un seul fichier main.tf | Orchestration par modules |

---

## ✅ Bonnes pratiques apprises

- Un module = une responsabilité
- Pas de provider dans les modules enfants
- Variables explicites
- Outputs utiles et documentés
- Root module = orchestration uniquement

---

## 🚀 Conclusion

Ce chapitre permet de :

- comprendre **comment structurer Terraform proprement**
- adopter une approche **scalable et maintenable**
- se rapprocher des standards professionnels

➡️ Prochaine étape possible :

- Chapitre 3 – Terraform + Environnements (dev / staging / prod)
- Chapitre 3 – Terraform + Remote State
- Chapitre 3 – Terraform + CI/CD

---

💬 Ce chapitre correspond exactement à ce qui est attendu d’un **Ingénieur DevOps** en mission ou en projet long.

