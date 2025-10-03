# Nouvelle Année

Chaque année au mois d'Octobre à une date décidée par la DGESCO une nouvelle année scolaire est mise à disposition des utilisateurs pour l'enregistrement de nouvelles PFMPs avec de nouveaux plafonds et potentiellement des nouvelles formations impactées par le dispositif.

## Description des étapes

### 1 - Conception des nouveaux fichiers Mefs et Wages

### 2 - Ajout des nouveaux fichiers Mefs et Wages dans le dossier /data du repo

La suite de test RSpec encapsule donc le parsing des nouveaux fichiers et signale toute erreur de parsing.

### 3 - Création dans le SchoolYearSeeder d'une nouvelle année

`SchoolYear.find_or_create_by(start_year: xxxx)`

### 4 - Adaptation de la suite de tests pour supporter la nouvelle année

Il y a encore certaines dates encodées en dur qui nécessitent d'être changées pour que tout fonctionne correctement.

### 5 - Déploiement de la nouvelle donnée en staging

Pour qu'elle soit accessible depuis un container Scalingo.

### 6 - Test de scénarios sur la nouvelle année en staging

Ex: Scénario de validation et paiement d'une PFMP avec un nouveau plafond.

### 7 - Déploiement en production de la nouvelle donnée (sans seeding)

### 8 - Activation de la nouvelle année

Un jour avant l'ouverture : créer la nouvelle année scolaire et déclencher les seeders sur la nouvelle donnée.

`SchoolYear.create!(start_year: xxxx)`
`WageSeeder.seed('data/wages/xxxx_xxxx.csv')`
`MefSeeder.seed('data/mefs/xxxx_xxxx.csv')`

### 9 - Création de potentielles exclusions du dispositif

Exemple :
`Exception.create!(uai: "XXXXX", mef_code: "132131312312", school_year: SchoolYear.current)`

### 10 - Récupération proactive des classes de la nouvelle année

`Sync::AllClassesJob.perform_later`


