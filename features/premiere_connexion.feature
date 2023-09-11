# language: fr

Fonctionnalité: Le personnel de direction se connecte
  Scénario: Le personnel de direction du MENJ peut se connecter
    Sachant que je suis un personnel MENJ directeur de l'établissement "1234567"
    Quand je me connecte en tant que personnel MENJ
    Alors le titre de la page contient "Liste des classes"
    Et la page contient "Nous récupérons la liste de vos élèves"

  Scénario: Le personnel de direction du MENJ doit choisir son établissement
    Sachant que je suis un personnel MENJ directeur de l'établissement "123, 456, 789"
    Quand je me connecte en tant que personnel MENJ
    Et que je sélectionne "123" pour "Établissement"
    Et que je clique sur "Continuez avec cet établissement"
    Alors la page contient "Nous récupérons la liste de vos élèves"
    Et la page contient "Lycée de la Mer Paul Bousquet"

  Scénario: Un personnel du MENJ sans établissements en responsabilité est informé
    Sachant que je suis un personnel MENJ de l'établissement "123"
    Quand je me connecte en tant que personnel MENJ
    Alors la page contient "aucun établissement sous votre direction"
