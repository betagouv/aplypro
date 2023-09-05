# language: fr

Fonctionnalité: Le personnel de direction saisit des coordonnées bancaires
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et qu'il y a une élève "Marie Curie" au sein de la classe "3EMEB" pour une formation "Développement"
    Et que je rafraîchis la page
    Et que je clique sur "Voir les élèves" dans la rangée "3EMEB"
    Et que je clique sur "Voir le profil de l'élève" dans la rangée "Curie Marie"

  Scénario: Le personnel de direction saisit un RIB pour la première fois
    Sachant que la page contient "Aucune coordonnées bancaires enregistrées"
    Et que je clique sur "Renseigner les coordonnées bancaires"
    Lorsque je renseigne des coordonnées bancaires
    Alors la page contient "Coordonnées bancaires enregistrées avec succès"
