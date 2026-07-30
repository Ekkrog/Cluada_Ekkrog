CREATE TYPE motif_visite AS ENUM ('reunion', 'livraison', 'entretien', 'autre');

CREATE TABLE visiteurs (
    id INT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL, 
    prenom VARCHAR(50) NOT NULL,
    societe VARCHAR(100) NOT NULL
);

CREATE TABLE visite (
    id_visiteurs INT NOT NULL,
    id_employe INT NOT NULL,
    date_visite DATE NOT NULL, 
    motif motif_visite NOT NULL,
    PRIMARY KEY (id_visiteurs, id_employe, date_visite),
    Foreign Key (id_visiteurs) REFERENCES visiteurs (id),
    Foreign Key (id_employe) REFERENCES employe (id)
);
