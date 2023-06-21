# language: fr

Fonctionnalité: Le personnel de direction saisit des coordonnées bancaires
  Contexte:
    Sachant que je suis directeur de l'établissement "DINUM"
    Et qu'il y a une élève "Marie Curie" au sein de la classe "3EMEB"
    Et que je me connecte
    Et que je clique sur "Voir les élèves" dans la rangée "3EMEB"
    Et que je clique sur "Voir le profil de l'élève" dans la rangée "Curie Marie"

  Scénario: Le personnel de direction saisit un RIB pour la première fois
    # Sachant que la page contient "Aucune coordonnées enregistrées"dans une section "Coordonnées bancaires"
    Sachant que la page contient "Aucune coordonnées enregistrées"
    Et que je clique sur "Renseigner les coordonnées bancaires"
    Et que je remplis "IBAN" avec "FR608761361276N1BLJ0ZGCJE80"
    Et que je remplis "BIC" avec "ANTSGB2LXXX"
    Et que je clique sur "Enregistrer"
    Alors la page contient "IBAN FR60XXXXXXXXXXXXXXXXXXXXXXX"
