# language: fr

Fonctionnalité: Le personnel de direction édite les PFMPs
  Contexte:
    Sachant que je suis directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Développement" rémunérée à 15 euros par jour et plafonnée à 200 euros par an
    Et qu'il y a une élève "Marie Curie" au sein de la classe "3EMEB" pour une formation "Développement"
    Et que je me connecte
    Et que je clique sur "Voir les élèves" dans la rangée "3EMEB"
    Et que je clique sur "Voir le profil de l'élève" dans la rangée "Curie Marie"

  Scénario: Le personnel de direction peut voir le nombre de PFMP réalisée
    Quand l'élève n'a réalisé aucune PFMP
    Alors la page contient "Aucune PFMP enregistrée pour le moment."

  Scénario: Le personnel de direction peut rajouter une PFMP
    Quand je renseigne une PFMP de 3 jours pour "Marie Curie"
    Alors la page contient "La PFMP a été enregistrée avec succès"
    Et je peux voir dans le tableau "Périodes de formation en milieu professionnel (PFMP)"
      | Début      | Fin        | Montant                      | État du paiement                    |
      | 17/03/2023 | 20/03/2023 | 3 jours × 15€ par jour = 45€ | Informations de paiement manquantes |

  Scénario: Le paiment est en attente dès que je rajoute les coordonnées bancaires
    Quand je consulte le profil de l'élève "Marie Curie"
    Et que je renseigne une PFMP de 4 jours pour "Marie Curie"
    Alors la page contient "Informations de paiement manquantes"
