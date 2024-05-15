# Tâches automatisées

Certaines tâches (i.e : Active Jobs) sont lancées à intervales
réguliers pour assurer le bon fonctionnement du système.

## Fonctionnement général

### Définitions

Tout le planning est défini dans le fichier `config/schedule.rb` qui
est un fichier consommé par la librairie
[`whenever`](https://github.com/javan/whenever).

Whenever interprète une syntaxe très naturelle et la traduit dans la
syntaxe compris par `cron` qui est l'option la plus simple disponible sur Scalingo.

### Mise à jour

Pour mettre à jour le planning il suffit de lancer

```sh
bin/rails schedule:regenerate
```

qui va se servir de `whenever` pour produire une syntaxe `cron` et
l'écrire dans un fichier à la racine du répértoire du projet qui
correspond aux exigences du Scalingo Scheduler.

https://doc.scalingo.com/platform/app/task-scheduling/scalingo-schedule
