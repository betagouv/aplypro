# Beta x Rails

![image](https://user-images.githubusercontent.com/107635/182360512-9fd4be19-bdf9-4a02-8f9c-94abf94e0164.png)


## Introduction

Ce repo est un kit de démarrage basé sur Ruby on Rails 7 avec le
[DSFR](https://www.systeme-de-design.gouv.fr/), notre [librairie de
composants DSFR](https://github.com/betagouv/dsfr-view-components)
ansi que certains outils choisis :

* RSpec comme framework de tests ;
* Cucumber et Capybara pour les tests BDD ;
* Rubocop (RSpec et Rails) pour le linting.

La base de données est configurée avec PostgreSQL.

MailCatcher est utilisé en développement pour intercepter les e-mails
envoyés.

## Démarrage

```shell
docker-compose up
```
