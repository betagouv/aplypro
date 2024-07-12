# language: fr

Fonctionnalité: Le personnel de direction peut constater les montants des PFMPs
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que mon établissement propose une formation "Développement" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et qu'il y a une élève "Marie Curie" au sein de la classe "2NDEB" pour une formation "Développement"
    Quand je rafraîchis la page
    Et que je clique sur "Classes"
    Et que je clique sur "Voir la classe" dans la rangée "2NDEB"
    Et que je clique sur "Voir le profil" dans la rangée "Curie Marie"

  Scénario: Le personnel de direction peut voir le montant original
    Quand je renseigne une PFMP de 3 jours
    Et je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État             | Nombre de jours | Montant |
      | Saisie à valider |               3 | 30 € |

  Scénario: Le personnel de direction peut voir le montant plafonné
    Quand je renseigne une PFMP de 11 jours
    Et je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État             | Nombre de jours | Montant |
      | Saisie à valider |              11 | 100 €   |

  Scénario: Le personnel de direction peut voir un montant plafonné par une autre PFMP
    Quand je renseigne une PFMP de 9 jours
    Et que je renseigne une PFMP de 2 jours
    Alors je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État             | Nombre de jours | Montant |
      | Saisie à valider |               9 | 90 €  |
      | Saisie à valider |               2 | 10 €  |

  Scénario: Le personnel de direction peut voir un montant nul pour une PFMP hors-plafond
    Quand je renseigne une PFMP de 9 jours
    Et que je renseigne une PFMP de 2 jours
    Et que je renseigne une PFMP de 4 jours
    Alors je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État             | Nombre de jours | Montant |
      | Saisie à valider |               9 | 90 €    |
      | Saisie à valider |               2 | 10 €    |
      | Saisie à valider |               4 | 0 €     |
