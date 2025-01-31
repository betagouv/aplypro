# language: fr

Fonctionnalité: Gestion des scolarités de l'élève
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "1MELEC" dont "Jean Dupuis" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte le profil de "Jean Dupuis" dans la classe de "1MELEC"
    Et que je clique sur "Masquer l'élève de la classe"
    Et que je clique sur "Confirmer le masquage de l'élève de la classe"

  Scénario: Le personnel veut réintégrer un élève retiré manuellement de la classe
    Alors la page contient "L'élève Jean Dupuis a bien été retiré de la classe 1MELEC"
    Et je peux voir dans le tableau "Élèves masqués manuellement de la classe"
      | Élèves (1)    | Réintégration de l'élève dans la classe      |
      | Dupuis Jean   | Réintégrer Jean Dupuis dans la classe 1MELEC |
    Quand je consulte le profil de "Jean Dupuis" dans la classe de "1MELEC"
    Alors la page contient "Masqué(e) manuellement de la classe"
    Quand je consulte la classe "1MELEC"
    Et que je clique sur "Réintégrer Jean Dupuis dans la classe 1MELEC"
    Et que je clique sur "Confirmer la réintégration de l'élève dans la classe"
    Alors la page ne contient pas "Élèves masqués manuellement de la classe"
    Quand je consulte le profil de "Jean Dupuis" dans la classe de "1MELEC"
    Alors la page contient "Masquer l'élève de la classe"

  Scénario: Les élèves retirés manuellement ne sont pas affichés dans les compteurs
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
