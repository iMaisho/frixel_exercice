## 🚀 TP 4 : Filtre, Tri et Pagination

Bienvenue dans ce quatrième TP de votre onboarding Elixir/Phoenix ! Ce TP est orienté sur la gestion de la donnée : recherche/filtre, pagination, tri. L'intégration de la traduction dynamique est incluse aussi. 

## 🎯 Objectifs principaux

- Approfondir l'usage des Lives (streams versus assigns)
- Filtrer dans le controller ou côté Ecto
- Gérer la langue de l'utilisateur
- Propager un choix utilisateur tout le long des pages (statiques, live) et sessions
- Intégrer une librairie de pagination et la configurer
- Gérer ses premières jointures

---

## ✅ Correction du TP 4

Ce repository contient la correction du TP 4 découpée en commits. Chaque commit correspond à un exercice (plus ou moins). 

## 📌 OBVIOUS:
  Avant de consulter la correction, réalisez le TP par vous-même.

## 📂 STEPS
Commit de "départ" : `977003050faad0c790a2c590181a99f945a3a40b`

1. Rajoutez un topic à la conversation. 
2. Utilitaire rapide pour wiper sa base. 
3. Filtrer les résultats de la Live Conversation - option 1 : Enum dans le Controller
4. Filtrer les résultats de la Live Conversation - option 2 : au travers d'Ecto
5. Initialiser la traduction 
6. Faire petit switch de traduction sur home page
7. Créer liens depuis la home page, rajouter la persistance du choix de langue
8. Persister le choix pour les Live
9. Pagination 1 : Sorting d'une table de données
10. Pagination 2 : Filtre d'une table de données (égalité stricte puis "élargie", bonus : sur les dates, bonus 2 : avec gettext du field)
11. Pagination 3 : Filtre d'une table de données sur jointure (Conversation has_many Messages)


## 📂 CORRECTIONS
Commit de "départ" : `977003050faad0c790a2c590181a99f945a3a40b`

1. Rajoutez un topic à la conversation : commit `8807d8d6d8a9acbbc2017321d90326fafe3711e5`
2. Utilitaire rapide pour wiper sa base : commit `43be4ea03dcd8851891678f4f776d5c3dcffa6b7`
3. Filtrer les résultats de la Live Conversation : commit `da140ddfedf81757fa3c239467a133780e24d455`
3. Filtrer les résultats de la Live Conversation - option 1 : Enum dans le Controller : commit `da140ddfedf81757fa3c239467a133780e24d455` pour égalité stricte, commit `8e5ccd884cb325160954794db7c148754b002889` pour regex
4. Filtrer les résultats de la Live Conversation - option 2 : au travers d'Ecto : commit `04f80c791d23aaf374391f7eb4b5e0b14f9c30fb` pour égalité stricte, commit `45ce5d2bf6658391345c7f08a107a37d9f2778ab` pour regex
5. Initialiser la traduction : commit `714754305d55edea8f4ff074f36e6faf8bf7d8ed`
6. Faire petit switch de traduction sur home page : commit `3125b70a159aaf20f2941108fba7d24314bf3423` basique, commit `bd1cc7c17013d44f61cac101e491dc7b5979662a` pour refacto en component
7. Créer liens depuis la home page, rajouter la persistance du choix de langue, commit : `f8b075d7a640b2043c1516ce98e8d451001be966`
8. Persister le choix pour les Live, commit : `658150707b032c36b852b0f30d75bd9d39471488`
9. Pagination 1 : Sorting d'une table de données, commit : `04303a1582dee35d12f02701054584c21cbffa4f` pour l'init, commit `fa406d4bf7142dc7fe3ba2ce0beccd1a66f2ff0b` avec un peu plus de CSS
10. Pagination 2 : Filtre d'une table de données, commit : `6884af6b6fc00f22172cac7701873eb4e25548eb` pour filtre Flop avec égalité stricte, commit :`5cc92c22fd59a9295246f10faaefe38738217dbc` pour ilike, commit : `bf5fb5ac645a922331484066b8fc37936e6fee26`
11. Pagination 3 : Filtre d'une table de données sur jointure (Conversation has_many Messages), commit : `68c63f1631111915526e3db979ed132d4ab899fe`. 


---

Bon apprentissage et bonne correction ! 🚀🔥