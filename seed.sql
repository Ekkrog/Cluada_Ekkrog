INSERT INTO visiteurs (id, nom, prenom, societe) VALUES 
(1, 'Poutina', 'Vladima', 'Cremelin'), 
(2, 'Dump', 'Donna', 'Whytaousse'),
(3, 'Oune', 'Quinejoue', 'Nocorea'),
(4, 'Padebiche', 'Steve', 'Marre-o-lingots'), 
(5, 'Maquereau', 'Manuel', 'Lafronsse'),
(6, 'Armand', 'Bruno', 'MLVH'),
(7, 'Miel', 'Xavier', 'Fruit');

INSERT INTO visite (id_visiteurs, id_employe, date_visite, motif) VALUES 
(1, 1, '2026-05-05', 'reunion'),
(2, 2, '2026-05-08', 'reunion'),
(3, 1, '2026-05-18', 'reunion'),
(4, 16, '2026-06-4', 'entretien'),
(5, 2, '2026-06-01', 'livraison'),
(6, 2, '2026-05-25', 'autre'),
(7, 16, '2026-06-14', 'livraison'),
(1, 1, '2026-05-30', 'autre'),
(2, 2, '2026-05-30', 'autre'),
(3, 3, '2026-05-30', 'autre'),
(5, 5, '2026-05-30', 'autre'),
(6, 6, '2026-05-30', 'autre'),
(7, 16, '2026-05-30', 'autre')
ON CONFLICT (id_visiteurs, id_employe, date_visite) DO NOTHING;