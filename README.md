# APLyPro

Allocation pour les lycéens professionnels.

## Introduction

Cette application sert de support aux personnels de lycées professionnels pour renseigner et payer les stages de moins de 2 mois, suivant les montants dictés par [l'arrêté du 11 août 2023](https://www.legifrance.gouv.fr/loda/id/JORFTEXT000047963979?init=true&page=1&query=allocation+lyc%C3%A9en&searchField=ALL&tab_selection=all).

## Pile technique

- Docker ;
- Ruby on Rails ;
- PostgreSQL ;
- RSpec ;
- Cucumber ;
- Keycloak : Gestion des utilisateurs ;
- [DSFR](https://www.systeme-de-design.gouv.fr/) .

[Dossier d'architecture technique](https://pad.numerique.gouv.fr/MBIlOHybQnGJBQE6LNFitw)

## Démarrage

```sh
git submodule update --init --recursive
make up
```

## Commandes utiles

Les commandes les plus fréquentes sont répertoriées et peuvent être
lancées à travers le fichier `Makefile`. Ces commandes sont démarrées
dans Docker.

Entre autres :

- `make cl` : lance une console Rails ;
- `make guard` : lance [Guard](https://github.com/guard/guard) ;
- `make sh` : lance un terminal ;
- `make lint` : lance Rubocop.

# Vocabulaire

Ministères :

- MENJ : Ministère de l'Éducation Nationale et de la Jeunesse ;
- MASA : Ministère de l'Agriculture et de la Souveraineté Alimentaire ;
- Mer : Secrétariat d'État Chargé De La Mer ;
- Armée : L'Armée.

Systèmes d'autentification :

- FIM : Federation Identity Manager : Pour MENJ, Mer et Armée
  - Passe par notre Keycloak
- CAS : Centralized Authentication Service : Pour MASA
  - Ne passe pas par notre Keycloak (à changer)

Sources de données :

- SYGNE : Expose les données des élèves du MENJ, provenant de la Base Établissements Élèves (BEE) ;
- FREGATA : Expose les données des élèves du MASA, provenant d'Educagri ;
- [Annuaire de l'Éducation](https://data.education.gouv.fr/api/v1/console/records/1.0/search/?dataset=fr-en-annuaire-education) : Données publiques des établissements. Ces données proviennent de RAMSES (appli de l'éducation nationale) et de l'ONISEP ([exemple](https://www.onisep.fr/ressources/univers-lycee/lycees/hauts-de-france/oise/lycee-professionnel-arthur-rimbaud)).

## Vocabulaire technique

- Décision d'attribution : Un document qui informe un élève de ses droits.
- PFMP : Période de Formation Professionnelle. C'est un stage.
- MEF : Module élémentaire de formation. Voir [la base de nomenclature](https://infocentre.pleiade.education.fr/bcn/workspace/viewTable/n/N_MEF).
- Schooling : Scolarité. Relie un élève à sa classe.
- Classe : Chaque classe est reliée à un code MEF.
