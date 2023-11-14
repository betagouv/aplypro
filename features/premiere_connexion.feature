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
    Alors la page contient "Année scolaire"
    Et la page contient "Lycée de la Mer Paul Bousquet"

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

  Scénario: Un personnel du MENJ peut-être invité lors de la bêta privée
    Sachant que l'accès est limité aux UAIs "123"
    Et que je suis un personnel MENJ directeur de l'établissement "123"
    Et que je me connecte en tant que personnel MENJ
    Et que j'autorise "louis.pasteur@education.gouv.fr" à rejoindre l'application
    Et que je me déconnecte
    Et que je suis un personnel MENJ de l'établissement "123" avec l'email "louis.pasteur@education.gouv.fr"
    Quand je me connecte en tant que personnel MENJ
    Alors la page contient "Bienvenue sur APLyPro"

  Scénario: Un personnel du MENJ dans un UAI pilote peut-être refusé
    Sachant que l'accès est limité aux UAIs "123"
    Et que je suis un personnel MENJ directeur de l'établissement "123"
    Et que je me connecte en tant que personnel MENJ
    Et que j'autorise "louis.pasteur@education.gouv.fr" à rejoindre l'application
    Et que je me déconnecte
    Et que je suis un personnel MENJ de l'établissement "123" avec l'email "jean.michel@education.gouv.fr"
    Quand je me connecte en tant que personnel MENJ
    Alors la page affiche une erreur d'authentification

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
