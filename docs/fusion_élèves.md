# Fusion élèves

## Description

Dans les SI du système éducatif français il n'est pas impossible qu'un élève physique se retrouve avec 2 INE. Lorsque c'est le cas il est possible qu'un retour d'intégration ASP échoue car il existe une contrainte d'unicité sur l'attribut `asp_individu_id`. Pour remédier à ces cas et relancer l'intégration il est nécessaire de dédoublonner l'objet `Student` qui pose problème. Il existe à cet effet la classe `StudentMerger`.

## Mode d'emploi

## Etape 1: sélectionner l'élève

En utilisant l'id qui remonte dans Sentry ou Sidekiq:

`student = Student.find_by!(asp_individu_id: asp_id)`

## Etape 2: Vérifier s'il y a des doublons

`students = Student.where(last_name: student.last_name, first_name: student.first_name, birthplace_city_inseecode: student.birthplace_city_inseecode, birthdate: student.birthdate)`

## Etape 3: Fusionner les élèves

`StudentMerger.new(students.to_a).merge!`

## Etape 4: Relancer les fichiers d'intégration

Cliquer "Retry Now" pour le job dans le panneau d'administration de Sidekiq.
