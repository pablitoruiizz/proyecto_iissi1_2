INSERT INTO Degrees VALUES (NULL, 'Tecnologías Informáticas', 4);
SELECT *
	FROM subjects s
	WHERE s.type = 'Obligatoria';
SELECT AVG(value)
	FROM grades g
	WHERE g.groupId = 1;
	
	#Consultas complejas
SELECT * 
   FROM Grades g
   ORDER BY g.value
;
#Ordenar en orden descendente y dando un prompt perteneciente a otra tabla
SELECT * 
   FROM Grades g
   WHERE g.value >= 5
	ORDER BY (SELECT s.surname
	         FROM Students s
	         WHERE s.studentId = g.studentId) 
	DESC
;
#limitar numero de resultados
SELECT * 
	FROM Grades g
	ORDER BY g.value DESC
	LIMIT 5
;
#Limitar numero de resultados y empezar a partir de x resultado
SELECT * 
	FROM Grades g
	ORDER BY g.value DESC
	LIMIT 5 OFFSET 5
;
SELECT *
	FROM Groups
	NATURAL JOIN GroupsStudents 
	NATURAL JOIN Students
;





