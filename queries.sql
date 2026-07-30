-- Active: 1785420028362@@127.0.0.1@5432@adakor
-- 1. La liste des employé·e·s avec le nom de leur service, triée par service puis par nom.

SELECT employe.nom, service.nom from employe
JOIN service on employe.service_id = service.id
ORDER BY service.nom, employe.nom;

-- 2. Le nombre d'employé·e·s par service.

SELECT count(employe.nom), service.nom from employe
JOIN service ON employe.service_id = service.id
GROUP BY service.nom;

-- 3. Le chiffre d'affaires total de la machine à café sur la période, en euros.

SELECT round(sum(prix_centimes)/100.0,2) AS CA FROM transaction_cafe;

-- 4. Le nombre de cafés tirés par boisson — quelle est la boisson la plus populaire chez Adakor ?

SELECT count(boisson), boisson FROM transaction_cafe
GROUP BY boisson
ORDER BY boisson;

-- La boisson la plus populaire est l'espresso 

-- 5. Le montant dépensé en café par personne (nom, prénom, total en euros), du plus dépensier au moins dépensier.

SELECT nom, prenom, sum(prix_centimes)/100 AS "depense (euros)" FROM employe
JOIN transaction_cafe ON employe.id = transaction_cafe.employe_id
GROUP BY employe.nom, employe.prenom
ORDER BY "depense (euros)" DESC;

-- 6. Les personnes qui tirent en moyenne plus de 4 cafés par jour de présence. Quelque chose te surprend ? Note-le en commentaire… puis va voir la question 7 avant de conclure.

SELECT employe.id, employe.nom, employe.prenom,
count(transaction_cafe.boisson) / count(DISTINCT date(transaction_cafe.horodatage)) AS moyenne 
FROM transaction_cafe
LEFT JOIN employe ON transaction_cafe.employe_id = employe.id
GROUP BY employe.id, employe.nom, employe.prenom
HAVING count(transaction_cafe.id) * 1.0 / count(DISTINCT DATE(transaction_cafe.horodatage)) > 4;

-- 7. Pour la personne repérée en 6 : à quelles heures tire-t-elle ses cafés ? Toutes les boissons sont-elles pour elle ? (Indice : personne ne boit 4 cappuccinos ET 3 chocolats ET 2 thés par jour. Hypothèse plausible : elle badge pour tout son open space. Une anomalie n'est pas une preuve.)

-- A toutes les heures, de 8h à 16h

SELECT employe_id, to_char(horodatage, 'YY-MM-DD') AS date, to_char(horodatage, 'HH24:MM:SS') AS heure FROM transaction_cafe WHERE employe_id = '3'
GROUP BY employe_id, horodatage
ORDER BY horodatage;

-- 8. Tous les badgeages effectués après 21h, triés par date. Observe les sens : des sorties tardives, c'est normal. Et le reste ?

SELECT to_char(horodatage, 'YY-MM-DD') AS date, to_char(horodatage, 'HH24:MM:SS') AS heure, sens FROM badgeage
WHERE EXTRACT(HOUR from horodatage) >= 21
ORDER BY horodatage; 

-- L'employe avec l'id 15 

-- 9. Isole les entrées après 21h. Qui ? Quelle porte ? Quelles dates ?

SELECT employe_id, horodatage, sens, porte FROM badgeage
WHERE EXTRACT(HOUR from horodatage) >= 21 AND sens = 'entree'
ORDER BY horodatage; 

-- Qui ? L'employe_id 15
-- Quelle porte ? La porte arrière
-- Quelles dates ? les 16, 17 et 18 juin

-- 10. Cette personne était-elle censée être là ? Croise avec la table conge : liste les badgeages effectués par un·e employé·e pendant l'un de ses congés.

SELECT conge.employe_id, conge.date_debut AS debut_conge, conge.date_fin AS fin_conge, horodatage FROM badgeage
JOIN conge ON badgeage.employe_id = conge.employe_id
WHERE badgeage.employe_id = 15 AND extract(hour from horodatage) >= 21
AND conge.date_debut <= '2026-06-16' AND conge.date_fin >= '2026-06-18';

-- 11. Le badge a aussi servi à la machine à café ces soirs-là. Prouve-le.

SELECT badgeage.employe_id, transaction_cafe.horodatage AS transactionCafe FROM badgeage JOIN transaction_cafe ON badgeage.employe_id = transaction_cafe.employe_id
WHERE badgeage.employe_id = 15
AND extract(hour FROM transaction_cafe.horodatage) >= 21
GROUP BY badgeage.employe_id, transaction_cafe.horodatage
HAVING extract(hour FROM transaction_cafe.horodatage) >= 21
ORDER BY transaction_cafe.horodatage;

-- 12. La question à 1 million : qui était physiquement présent·e ces soirs-là ? Le badge de la porte peut s'emprunter… mais on vient en voiture avec son propre badge de parking. Croise les accès parking avec les horaires des badgeages suspects.

SELECT DISTINCT e.id, e.nom, ap.horodatage AS acces_parking, sens
FROM acces_parking ap
JOIN employe e ON e.id = ap.employe_id
WHERE DATE(ap.horodatage) BETWEEN '2026-06-16' AND '2026-06-18' 
AND extract(hour from ap.horodatage) >= 21
AND ap.sens = 'entree';

-- 13. Vérifie ton hypothèse : la personne suspectée a-t-elle badgé à une porte avec son propre badge ces soirs-là ? Que faisait-elle les jours en question (ses badgeages en journée) ?

SELECT employe_id, porte, sens, horodatage FROM badgeage
WHERE employe_id = 16
GROUP BY employe_id, porte, sens, horodatage
HAVING date(horodatage) BETWEEN '2026-06-16' AND '2026-06-18'
ORDER BY date(horodatage), extract(HOUR from horodatage);

SELECT e.nom nom_employe, e.prenom prenom_employe, visiteurs.nom visiteur_nom, visiteurs.prenom visiteur_prenom, date_visite FROM visite 
JOIN employe e ON visite.id_employe = e.id
JOIN visiteurs on visite.id_visiteurs = visiteurs.id;

SELECT e.prenom, e.nom, count(date_visite) nbVisites from employe e JOIN visite ON e.id = visite.id_employe
GROUP BY e.nom, e.prenom; 