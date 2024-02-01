# APLyPro

Allocation pour les lycéens professionnels.

## Introduction

Cette application servira de support aux personnels de direction pour
renseigner et faciliter le paiement des périodes de stage en milieu
professionnel (PFMP).

## Pile technique

- Ruby 3 ;
- Ruby on Rails 7 ;
- Keycloak ;
- RSpec ;
- Cucumber.

## Démarrage

```sh
git submodule update --init --recursive
docker-compose up
```


# Trucs à savoir

Ministères :
- MENJ : Ministère de l'éducation nationale et de la jeuness
- MASA : Ministère de l'agriculture
- Mer : Secrétariat d'État Chargé De La Mer
- Armée : L'Armée

Authentifications :
- FIM : Federation Identity Manager : Pour le MENJ et la Mer et l'armée
  - Passe par notre keycloak
- CAS : Centralized Authentication Service : Pour le MASA
  - Passe pas par notre keycloak

## Vocabulaire :

PFMP : Période de Formation Professionnelle. C'est un stage.
MEF : Module élémentaire de formation. Voir [la base de nomenclature](https://infocentre.pleiade.education.fr/bcn/workspace/viewTable/n/N_MEF)
Schooling : Scolarité. Relie un élève à sa classe
Classe : Relié à un code MEF
Décision d'attribution : Un document PDF qui informe un élève de ses droits
