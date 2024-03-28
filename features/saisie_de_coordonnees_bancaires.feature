# language: fr

Fonctionnalité: Le personnel de direction saisit des coordonnées bancaires
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et qu'il y a une élève "Marie Curie" au sein de la classe "2NDEB" pour une formation "Développement"
    Et que je consulte le profil de "Marie Curie" dans la classe de "2NDEB"

  Scénario: Le personnel de direction saisit un RIB pour la première fois
    Sachant que la page contient "Aucune coordonnée bancaire enregistrée"
    Et que je clique sur "Saisir les coordonnées bancaires"
    Lorsque je renseigne des coordonnées bancaires
    Alors la page contient "Coordonnées bancaires enregistrées avec succès"

  Scénario: Le personnel de direction peut modifier un RIB
    Sachant que je clique sur "Saisir les coordonnées bancaires"
    Et que je renseigne des coordonnées bancaires
    Et que je clique sur "Modifier les coordonnées bancaires"
    Et que je remplis "Titulaire du compte" avec "Murie Carrie"
    Et que je clique sur "Modifier les coordonnées bancaires"
    Alors la page contient "Coordonnées bancaires mises à jour"
    Et la page contient "Murie Carrie"

  Scénario: Le personnel de direction peut supprimer un RIB
    Sachant que je clique sur "Saisir les coordonnées bancaires"
    Et que je renseigne des coordonnées bancaires
    Et que je clique sur "Supprimer les coordonnées bancaires"
    Quand je clique sur "Confirmer la suppression"
    Alors la page contient "Les coordonnées bancaires de Marie Curie ont bien été supprimées"
    Et la page contient "Aucune coordonnée bancaire enregistrée pour le moment."
