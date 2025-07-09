# APIs pour la récupération des élèves

L'allocation pour les lycéens professionnels concerne des formations
dispensées par quatre ministères :

* le Ministère de l'Éducation et de la Jeunesse (MENJ) ;
* le Ministère de l'Agriculture et de la Souveraineté Alimentaire (MASA) ;
* le Ministère des Armées ;
* le secrétariat d'État chargé de la Mer.

Pour importer ces élèves, plusieurs sources sont utilisées :

* SYGNE pour le MENJ, les Armées et la Mer ;
* FREGATA pour le MASA ;
* un import CSV est aussi disponible bien qu'expérimental.

Ces deux premières APIs (HTTPs) n'ayant pas les mêmes terminaisons ou
les mêmes topologies de données, APLyPro doit effectuer un travail
d'harmonisation et de réconciliation pour offrir une seule interface,
pour l'utilisateur comme pour le développeur.

## StudentsApi

La classe `StudentsApi` permet de demander l'une des deux APIs, par
exemple : `StudentsApi.api_for("sygne")`. Les établissements stockent
leur fournisseur d'élève dans l'attribut `students_provider`. D'où

```rb
class Establishment
  # [...]
  def students_api
    StudentsApi.api_for(students_provider)
  end
end
```

## Types de ressources

La classe retournée (par exemple : `StudentsApi::Sygne::Api`) permet
de demander trois types de ressources :

* les élèves d'un établissement ;
* les information d'un seul élève ;
* les scolarités d'un seul élève.

grâce à la fonction `fetch_resource(resource_type, params)`. Ces
données sont récapitulées dans le tableau suivant :

| paramètre `resource_type` | type de ressources               | terminaison SYGNE              | terminaison FREGATA                    |
|---------------------------|----------------------------------|--------------------------------|----------------------------------------|
| :establishment_students   | Les élèves d'un établissment     | `/etablissements/{uai}/eleves` | `/inscriptions?rne={uai}`              |
| :student                  | Les informations d'un seul élève | `/eleves/{ine}`                | `/inscriptions?rne={uai}` **voir [1]** |
| :student_schoolings       | Les scolarités d'un seul élève   | `/eleves/{ine}`                | pas implémenté                         |


**IMPORTANT** [1]: FREGATA ne fournit pas de terminaison basée sur un
simple INE (à la connaissance de l'auteur). Comme la terminaison des
listes d'élèves fournit l'intégralité des données nécessaires pour
APLyPro, on utilise cette dernière pour récupérer tous les élèves puis
aller chercher l'élève demandé.

## Sécurisation des APIS

SYGNE utilise OAuth2.0 pour authentifier les requêtes.

FREGATA utilise HMAC.

## Exploration des APIs

Les APIs sont concues pour pouvoir être explorées / debuggées
facilement car elles exposent une méthode `get(endpoint)` qui permet
de faire un appel à une terminaison avec l'authentification
nécessaire de chaque côté :

```rb
StudentsApi::Sygne::Api.get("/nouvelle/terminaison/hypothétique")
StudentsApi::Fregata::Api.get("/autre/terminaison/hypothétique")
```

## Création de données

Le répertoire `mock` simule ses terminaisons et peut générer des
données semblables à celles de production grâce à des factories
paramétrables pour chaque terminaison d'API, par exemple celle de
SYGNE :

`mock/apis/factories/sygne/`

La forme finale de ces données peut être constatée avec :


```sh
make sh

apt-get install -y curl jq

curl mock:3002/sygne/etablissements/007/eleves
```

N.B : on a encodé en dur pour l'exemple au dessus mais les terminaisons d'API
peuvent être interrogées avec :

```rb
irb(main):001> StudentsApi::Sygne::Api.establishment_students_endpoint(uai: "007")

=> "http://mock:3002/sygne/etablissements/007/eleves/?etat-scolarisation=true"
```
