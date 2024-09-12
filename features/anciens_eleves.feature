# language: fr

Fonctionnalité: Les anciens élèves sont inclus à part dans l'interface
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "1MELEC" dont "Jean Dupuis" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que l'élève "Jean Dupuis" a quitté l'établissement "DINUM"

  Scénario: Les anciens élèves sont affichés dans le compteur des décisions d'attribution
    Quand je rafraîchis la page
    Alors le panneau "Décisions d'attribution" contient "0 / 10"
    Et le panneau "Décisions d'attribution" contient "Éditer 10 décisions d'attribution manquantes"

  Scénario: Les anciens élèves sont affichés dans le compteur des saisies bancaires
    Quand je rafraîchis la page
    Alors le panneau "Coordonnées bancaires" contient "0 / 10"

  Scénario: Les élèves qui ont changé de classe au sein du même établissement sont correctement comptabilisés dans la page d'accueil
    Sachant que l'élève "Jean Dupuis" a une ancienne scolarité dans la classe "2NDEB" dans le même établissement
    Quand je rafraîchis la page
    Alors le panneau "Décisions d'attribution" contient "0 / 11"
    Et le panneau "Coordonnées bancaires" contient "0 / 10"

  Scénario: Les anciens élèves sont affichés dans les listings de classe
    Quand je consulte la liste des classes
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs |
      | 1MELEC |                  0 / 10 |                0 / 10 |       |

  Scénario: Les élèves qui ont changé de classe au sein du même établissement sont correctement comptabilisés dans la liste des classes
    Sachant que l'élève "Jean Dupuis" a une ancienne scolarité dans la classe "2NDEB" dans le même établissement
    Quand je consulte la liste des classes
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs |
      | 1MELEC |                  0 / 10 |                0 / 10 |       |
      | 2NDEB  |                  0 / 1  |                0 / 1  |       |

  Scénario: Les anciens élèves sont affichés dans une section à part dans la page d'une classe
    Quand je consulte la classe de "1MELEC"
    Alors je peux voir dans le tableau "Élèves sortis de la classe"
      | Élèves (1)  | Décisions d'attribution (0/1) | Coordonnées Bancaires (0/1) | PFMPs (0) |
      | Dupuis Jean |                               |                             |           |

  Scénario: Le personnel peut générer des décisions d'attribution pour les anciens élèves
    Lorsque je me rends sur la page d'accueil
    Et que je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Quand je me rends sur la page d'accueil
    Alors la page contient "Télécharger 10 décisions d'attribution"
    Et le panneau "Décisions d'attribution" contient "10 / 10"

  Scénario: Le personnel voit le bouton pour générer des décisions d'attribution même si il n'y a que des anciens élèves qui n'en ont pas
    Lorsque les élèves actuels sont les seuls à avoir des décisions d'attribution
    Et que je me rends sur la page d'accueil
    Alors la page contient "Télécharger 9 décisions d'attribution"
    Et la page contient "Éditer la décision d'attribution manquante"

  Scénario: Le personnel peut renseigner des coordonnées bancaires pour des anciens élèves
    Quand je renseigne les coordonnées bancaires de l'élève "Jean Dupuis" de la classe "1MELEC"
    Et que je consulte la classe de "1MELEC"
    Alors je peux voir dans le tableau "Élèves sortis de la classe"
      | Élèves (1)  | Décisions d'attribution | Coordonnées Bancaires (1/1) | PFMPs (0) |
      | Dupuis Jean |                         | Saisies                     |           |

  Scénario: Le personnel peut créer une PFMP pour un ancien élève
    Quand je consulte la classe de "1MELEC"
    Et que je renseigne une PFMP de 3 jours pour "Dupuis Jean"
    Alors la page contient "La PFMP a bien été enregistrée"
    Et je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État             | Nombre de jours | Montant |
      | Saisie à valider |               3 |         |

  Scénario: Le personnel peut compléter les PFMPs pour les anciens élèves
    Quand je consulte la classe de "1MELEC"
    Et que je renseigne une PFMP pour "Dupuis Jean"
    Et que je consulte la classe de "1MELEC"
    Et que je clique sur "Compléter 1 PFMP"
    Et que je peux voir dans le tableau "Liste des pfmps à compléter de la classe 1MELEC"
      | Élève                               |
      | Dupuis Jean Sorti(e) de la classe   |
    Et que je remplis le champ "Nombre de jours" dans la rangée "Dupuis Jean" avec "3"
    Lorsque je clique sur "Enregistrer 1 PFMP"
    Alors la page contient "Les PFMPs ont bien été modifiées"
    Et je peux voir dans le tableau "Élèves sortis de la classe"
      | Élèves (1)    | Décisions d'attribution | Coordonnées Bancaires | PFMPs (1)                  |
      | Dupuis Jean   |                         |                       | Saisie à valider mars 2025 |

  Scénario: Le personnel peut voir les PFMPs à valider des anciens élèves
    Quand je consulte la classe de "1MELEC"
    Et que je renseigne une PFMP de 3 jours pour "Dupuis Jean"
    Et que la dernière PFMP de "Jean Dupuis" est validable
    Et que je clique sur "Paiements"
    Alors je peux voir 1 PFMP "Saisies à valider" pour la classe "1MELEC"
    Quand je clique sur "1MELEC"
    Alors je peux voir dans le tableau "Liste des pfmps à valider"
      | Élève       | PFMP      | Nombre de jours | Montant |
      | Dupuis Jean | mars 2025 | 3 jours         |         |
    Et la rangée "Dupuis Jean" contient "Sorti(e) de la classe"

  Scénario: Le personnel peut valider les PFMPs des anciens élèves
    Quand je consulte la classe de "1MELEC"
    Et que je renseigne une PFMP de 3 jours pour "Dupuis Jean"
    Et que la dernière PFMP de "Jean Dupuis" est validable
    Et que je clique sur "Paiements"
    Et que je clique sur "1MELEC"
    Et que je coche la case de responsable légal
    Lorsque je clique sur "Envoyer en paiement les PFMPs cochées"
    Alors la page contient "PFMPs envoyées en paiement pour la classe 1MELEC"
    Lorsque je clique sur "Classes"
    Et que je clique sur "1MELEC"
    Alors je peux voir dans le tableau "Élèves sortis de la classe"
      | Élèves      | Décisions d'attribution | Coordonnées bancaires | PFMPs             |
      | Dupuis Jean |                         |                       | Validée mars 2025 |

  Scénario: Le personnel peut consulter le profil des anciens élèves
    Quand je consulte la classe de "1MELEC"
    Et que je clique sur "Dupuis Jean"
    Alors la page contient "Sorti(e) de la classe"
