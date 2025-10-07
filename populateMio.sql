INSERT INTO Degrees VALUES (NULL, 'Tecnologías Informáticas', 4);
SELECT *
	FROM subjects s
	WHERE s.type = 'Obligatoria';
SELECT AVG(value)
	FROM grades g
	WHERE g.groupId = 1;