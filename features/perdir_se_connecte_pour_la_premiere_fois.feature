# language: fr

Fonctionnalité: Le personnel de direction se connecte
  Scénario: Le personnel de direction se connecte pour la première fois
    Sachant que je suis directeur de l'établissement "DINUM"
    Et que mon établissement n'est pas encore hydraté
    Quand je me connecte
    Alors le titre de la page contient "Tableau de bord"
    Et la page contient "Nous récupérons la liste de vos élèves"

  Scénario: Le personnel de direction se connecte
    Sachant que je suis directeur de l'établissement "DINUM"
    Et que mon établissement a été hydraté
    Quand je me connecte
    Alors le titre de la page contient "Tableau de bord"
    Et la page contient "4 classes"
