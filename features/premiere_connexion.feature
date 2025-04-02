# language: fr

Fonctionnalité: Le personnel de direction se connecte
  Scénario: Le personnel de direction du MENJ peut se connecter
    Sachant que je suis un personnel MENJ directeur de l'établissement "1234567"
    Quand je me connecte en tant que personnel MENJ
    Alors la page contient "Bienvenue sur APLyPro"
    Et que je clique sur "Continuer"
    Alors la page contient "Année scolaire"

  Scénario: Le personnel de direction du MASA peut se connecter
    Sachant que je suis un personnel MASA directeur de l'établissement "1234567"
    Quand je me connecte en tant que personnel MASA
    Alors la page contient "Bienvenue sur APLyPro"
    Et que je clique sur "Continuer"
    Alors la page contient "Année scolaire"

  Scénario: Le personnel de direction du MENJ doit choisir son établissement
    Sachant que je suis un personnel MENJ directeur de l'établissement "123, 456, 789"
    Quand je me rends sur la page d'accueil
    Et que je clique sur "Se connecter (MENJ)"
    Et que je sélectionne "123" pour "Établissement"
    Et que je clique sur "Continuez avec cet établissement"
    Et que je passe l'écran d'accueil
    Et la page contient "Lycée de la Mer Paul Bousquet"

  Scénario: Le personnel peut changer d'établissement
    Sachant que je suis un personnel MENJ directeur de l'établissement "123, 456, 789"
    Et je me rends sur la page d'accueil
    Et que je clique sur "Se connecter (MENJ)"
    Et que je sélectionne "123" pour "Établissement"
    Et que je clique sur "Continuez avec cet établissement"
    Et que je passe l'écran d'accueil
    Quand je clique sur "Changer d'établissement"
    Et que je sélectionne "456" pour "Établissement"
    Et que je clique sur "Continuez avec cet établissement"
    Alors la page contient "456"

  Scénario: Un personnel du MENJ sans établissements en responsabilité est informé
    Sachant que je suis un personnel MENJ de l'établissement "123"
    Quand je me connecte en tant que personnel MENJ
    Alors la page affiche une erreur d'authentification
    Mais il y a un compte utilisateur enregistré

  Scénario: Un personnel de direction du MENJ peut se reconnecter sans problèmes
    Sachant que je suis un personnel MENJ directeur de l'établissement "123"
    Et que je me connecte en tant que personnel MENJ
    Et que je me déconnecte
    Quand je me connecte en tant que personnel MENJ
    Alors le titre de la page contient "Accueil"

  Scénario: Un personnel du MENJ sans UAI dans son FrEduRne peut se connecter si il a une invitation
    Sachant que je suis un personnel MENJ directeur de l'établissement "123"
    Et que je me connecte en tant que personnel MENJ
    Et que j'autorise "jean.michel@education.gouv.fr" à rejoindre l'application
    Et que je me déconnecte
    Et que je suis un personnel MENJ sans FrEduRne avec l'email "jean.michel@education.gouv.fr"
    Quand je me connecte en tant que personnel MENJ
    Alors la page contient "Bienvenue sur APLyPro"

  # Les personnels de la Mer passent par la FIM mais n'ont pas les
  # attributs "FrEduRneResp" et "FrEduFonctAdm" renseignés, c'est un
  # choix volontaire du côté de la FIM. Pour palier au problème nous
  # avons un attribut spécifique que nous pouvons renseigner pour
  # forcer l'association entre le profil et un établissement en
  # responsabilité.
  Scénario: Un personnel de direction de la MER peut être introduit dans l'application
    Sachant que je suis un personnel MENJ avec un accès spécifique pour l'UAI "456"
    Quand je me connecte en tant que personnel MENJ
    Alors la page contient "Connexion réussie"

  Scénario: Le changement d'établissement n'est pas visible quand il n'y en a qu'un seul
    Sachant que je suis un personnel MENJ directeur de l'établissement "123"
    Quand je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Alors la page ne contient pas "Changer d'établissement"

  Scénario: Un personnel change de rôle pour un établissement
    Sachant que je suis un personnel MENJ de l'établissement "123" avec une délégation DELEG-CE pour APLyPro
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Alors la page ne contient pas "Gestion des accès"
    Et que je me déconnecte
    Et que j'ai désormais le rôle de directeur pour l'établissement "123"
    Et que je me connecte en tant que personnel MENJ
    Alors la page contient "Gestion des accès"

  Scénario: Un personnel du MASA peut gérer un établissement du MENJ
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je me déconnecte
    Et que je suis un personnel MASA directeur de l'établissement "DINUM"
    Quand je me connecte en tant que personnel MASA
    Alors je peux voir l'écran d'accueil

  Scénario: Le personnel de direction du MENJ ne peut plus accéder à ses anciens établissements
    Sachant que je suis un personnel MENJ directeur de l'établissement "ETAB1, ETAB2" avec l'email "marie.curie@education.gouv.fr"
    Et je me rends sur la page d'accueil
    Et que je clique sur "Se connecter (MENJ)"
    Et que je sélectionne "ETAB2" pour "Établissement"
    Et que je clique sur "Continuez avec cet établissement"
    Et que je passe l'écran d'accueil
    Et que je clique sur "Changer d'établissement"
    Alors la page contient "ETAB1"
    Et la page contient "ETAB2"
    Quand je me déconnecte
    Sachant que je suis un personnel MENJ directeur de l'établissement "ETAB1" avec l'email "marie.curie@education.gouv.fr"
    Et que je me connecte en tant que personnel MENJ
    Alors la page ne contient pas "Changer d'établissement"
    Et la page contient "ETAB1"
    Et la page ne contient pas "ETAB2"
