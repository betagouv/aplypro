# language: fr

Fonctionnalité: Complétion des PFMPs d'une classe
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et qu'il y a une élève "Marie Curie" au sein de la classe "2NDEB" pour une formation "2NDEPRO Développement"
    Et qu'il y a un élève "Paul Langevin" au sein de la classe "2NDEB" pour une formation "2NDEPRO Développement"
    Et que je saisis une PFMP pour toute la classe "2NDEB" avec les dates "17/03/2023" et "20/03/2023"
    Et que je clique sur "Compléter 2 PFMPs"
    Et que je remplis le champ "Nombre de jours" dans la rangée "Curie Marie" avec "12"
    Et que je remplis le champ "Nombre de jours" dans la rangée "Langevin Paul" avec "4"
    Et que je clique sur "Enregistrer 2 PFMPs"
    Et que je clique sur "Envoyer en paiement"
  
  Scénario: Le personnel peut accéder à la page des classes avec PFMPs à valider
    Alors la page contient "2NDEB - Développement"
    Et je peux voir 2 PFMP "Saisies à valider" pour la classe "2NDEB"

  Scénario: Le personnel de direction voit le nom du directeur confirmé existant
    Sachant que mon établissement a un directeur confirmé nommé "Jean Dupuis"
    Quand je clique sur "2NDEB - Développement"
    Alors la page contient "Vous remplacerez Jean Dupuis"
  
  Scénario: Le personnel peut accéder à la page de validation des PFMPs saisies à valider d'une classe
    Lorsque je clique sur "2NDEB - Développement"
    Alors la page contient "Envoyer en paiement les PFMPs de 2NDEB"
    Et la page contient "1 € par jour travaillé"
    Et la page contient "100 € de plafond annuel"
    Et je peux voir dans le tableau "Liste des pfmps à valider"
      | Élève         | PFMP      | Nombre de jours | Montant |
      | Curie Marie   | mars 2023 | 12 jours        | 12 €    |
      | Langevin Paul | mars 2023 | 4 jours         | 4 €     |

  Scénario: Le personnel ne peut pas valider les PFMPs sans cocher la case de responsable légal
    Et que je clique sur "2NDEB - Développement"
    Et que je décoche la case de responsable légal
    Lorsque je clique sur "Envoyer en paiement les PFMPs cochées"
    Alors la page contient "Vous devez être chef d'établissement"

  Scénario: Le personnel peut valider les PFMPs d'une classe
    Et que je clique sur "2NDEB - Développement"
    Et que je coche la case de responsable légal
    Lorsque je clique sur "Envoyer en paiement les PFMPs cochées"
    Alors la page contient "PFMPs envoyées en paiement pour la classe 2NDEB"
    Lorsque je clique sur "Élèves"
    Et que je clique sur "2NDEB"
    Alors je peux voir dans le tableau "Liste des élèves"
      | Élèves        | Décisions d'attribution | Coordonnées bancaires | PFMPs             |
      | Curie Marie   |                         |                       | Validée mars 2023 |
      | Langevin Paul |                         |                       | Validée mars 2023 |

  Scénario: Le personnel peut décocher des PFMPs pour éviter de les valider
    Et que je clique sur "2NDEB - Développement"
    Et que je décoche "Curie Marie"
    Et que je coche la case de responsable légal
    Lorsque je clique sur "Envoyer en paiement les PFMPs cochées"
    Alors la page contient "PFMPs envoyées en paiement pour la classe 2NDEB"
    Lorsque je clique sur "Élèves"
    Et que je clique sur "2NDEB"
    Alors je peux voir dans le tableau "Liste des élèves"
      | Élèves        | Décisions d'attribution | Coordonnées bancaires | PFMPs                      |
      | Curie Marie   |                         |                       | Saisie à valider mars 2023 |
      | Langevin Paul |                         |                       | Validée mars 2023          |

  Scénario: Le personnel ne peut pas valider si toutes les PFMPs sont décochées
    Et que je clique sur "2NDEB - Développement"
    Et que je décoche "Curie Marie"
    Et que je décoche "Langevin Paul"
    Et que je coche la case de responsable légal
    Lorsque je clique sur "Envoyer en paiement les PFMPs cochées"
    Alors la page contient "Vous devez sélectionner au moins une PFMP pour pouvoir valider"