# language: fr

Fonctionnalité: Le personnel de direction se connecte
  Scénario: Le personnel de direction du MENJ peut se connecter
    Sachant que je suis un personnel MENJ directeur de l'établissement "1234567"
    Quand je me connecte en tant que personnel MENJ
    Alors le titre de la page contient "Liste des classes"
    Et la page contient "Nous récupérons la liste de vos élèves"

  Scénario: Le personnel de direction du MENJ doit choisir son établissements
    Sachant que je suis un personnel MENJ directeur de l'établissement "123, 456, 789"
    Quand je me connecte en tant que personnel MENJ
    Alors le titre de la page contient "Choix de l'établissement"
