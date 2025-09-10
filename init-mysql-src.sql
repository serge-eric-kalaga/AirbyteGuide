CREATE EXTENSION IF NOT EXISTS vector;


-- Création de la table utilisateur
CREATE TABLE IF NOT EXISTS utilisateur (
	id SERIAL PRIMARY KEY,
	username VARCHAR(50) NOT NULL UNIQUE,
	email VARCHAR(100) NOT NULL UNIQUE
);


-- Création de la table tâche
CREATE TABLE IF NOT EXISTS tache (
	id SERIAL PRIMARY KEY,
	title VARCHAR(100) NOT NULL,
	description TEXT,
	due_date DATE,
	is_completed BOOLEAN DEFAULT FALSE,
	utilisateur_id INTEGER REFERENCES utilisateur(id)
);


-- Insertion de données d'exemple dans utilisateur
INSERT INTO utilisateur (username, email) VALUES
('alice', 'alice@example.com'),
('bob', 'bob@example.com'),
('carol', 'carol@example.com');


-- Insertion de données d'exemple dans tache
INSERT INTO tache (title, description, due_date, is_completed, utilisateur_id) VALUES
('Acheter du lait', 'Acheter du lait au supermarché', '2025-09-11', FALSE, 1),
('Finir le rapport', 'Compléter le rapport annuel', '2025-09-15', FALSE, 2),
('Appeler le client', 'Appeler le client pour le suivi', '2025-09-12', TRUE, 1),
('Réunion équipe', 'Réunion hebdomadaire avec l''équipe', '2025-09-13', FALSE, 3);

