# language: fr

Fonctionnalité: Gestion des scolarités de l'élève
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "1MELEC" dont "Dupuis Jean" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte le profil de "Dupuis Jean" dans la classe de "1MELEC"

  Scénario: Les dates de scolarité de l'élève sont affichées
    Alors la page contient "Scolarité débutée le 02/09/2024"
    Et la page ne contient pas "et finie le"
    Quand je clique sur "Ajouter une PFMP"
    Alors la page contient "(entre le 02/09/2024 et le 01/09/2025)"
    Sachant que l'élève "Dupuis Jean" a une date de début et une date de fin de scolarité
    Et que je consulte le profil de "Dupuis Jean" dans la classe de "1MELEC"
    Alors la page contient "Scolarité débutée le 01/09/2024 et finie le 30/06/2025"
    Quand je clique sur "Ajouter une PFMP"
    Alors la page contient "(entre le 01/09/2024 et le 30/06/2025)"

  Scénario: Le personnel veut réintégrer un élève retiré manuellement de la classe
    Quand je clique sur "Masquer l'élève de la classe"
    Et que je clique sur "Confirmer le masquage de l'élève de la classe"
    Alors la page contient "L'élève Dupuis Jean a bien été retiré de la classe 1MELEC"
    Et je peux voir dans le tableau "Élèves masqués manuellement de la classe"
      | Élèves (1)    | Réintégration de l'élève dans la classe      |
      | Dupuis Jean   | Réintégrer Dupuis Jean dans la classe 1MELEC |
    Quand je consulte le profil de "Dupuis Jean" dans la classe de "1MELEC"
    Alors la page contient "Masqué(e) manuellement de la classe"
    Quand je consulte la classe "1MELEC"
    Et que je clique sur "Réintégrer Dupuis Jean dans la classe 1MELEC"
    Et que je clique sur "Confirmer la réintégration de l'élève dans la classe"
    Alors la page ne contient pas "Élèves masqués manuellement de la classe"
    Quand je consulte le profil de "Dupuis Jean" dans la classe de "1MELEC"
    Alors la page contient "Masquer l'élève de la classe"

  Scénario: Les élèves retirés manuellement ne sont pas affichés dans les compteurs
    Quand je clique sur "Masquer l'élève de la classe"
    Et que je clique sur "Confirmer le masquage de l'élève de la classe"
    Alors je peux voir dans le tableau "Liste des élèves"
      | Élèves (9)    | Décisions d'attribution (0/9) | Coordonnées Bancaires (0/9) |
    Et la page contient "Saisir 9 coordonnées bancaires"
    Quand je me rends sur la page d'accueil
    Alors le panneau "Décisions d'attribution" contient "0 / 9"
    Et le panneau "Décisions d'attribution" contient "Éditer 9 décisions d'attribution manquantes"
    Et le panneau "Coordonnées bancaires" contient "0 / 9"
    Quand je consulte la liste des classes
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs |
      | 1MELEC |                  0 / 9  |                0 / 9  |       |
