# language: fr

Fonctionnalité: Gestion des délégations par DELEG-CE
  Scénario: Je peux me connecter à l'application si j'ai une délégation DELEG-CE dans mes attributs
    Sachant que je suis un personnel MENJ de l'établissement "DINUM" avec une délégation DELEG-CE pour APLyPro
    Lorsque je me connecte en tant que personnel MENJ
    Alors la page contient "Bienvenue sur APLyPro"

  Scénario: Je suis considéré comme un invité et non un chef d'établissement si j'ai une délégation DELEG-CE
    Sachant que je suis un personnel MENJ de l'établissement "DINUM" avec une délégation DELEG-CE pour APLyPro
    Et que je me connecte en tant que personnel MENJ
    Lorsque l'API SYGNE renvoie 1 élèves en "1MELEC" pour l'établissement "DINUM"
    Et que toutes les tâches de fond sont terminées
    Et que je passe l'écran d'accueil
    Alors je n'ai pas accès aux actions de chef d'établissement

  Scénario: Je ne peux pas accéder à l'application si ma délégation DELEG-CE est mal formée
    Sachant que je suis un personnel MENJ de l'établissement "DINUM" avec une mauvaise délégation DELEG-CE pour APLyPro
    Lorsque je me connecte en tant que personnel MENJ
    Alors la page affiche une erreur d'authentification

  Scénario: Je peux voir les données de mon établissement
    Sachant que je suis un personnel MENJ de l'établissement "DINUM" avec une délégation DELEG-CE pour APLyPro
    Lorsque je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Alors la page contient "Lycée de la Mer Paul Bousquet"
