DROP DATABASE if EXISTS gradosdb;
CREATE DATABASE if NOT EXISTS gradosdb;
USE gradosdb;

CREATE TABLE Degrees(
	degreeId INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(60) NOT NULL,
	years INT DEFAULT(4) NOT NULL,
	PRIMARY KEY (degreeId),
	CONSTRAINT invalidDegreeYear CHECK (years >=3 AND years <=5),
	CONSTRAINT uniqueDegreeName UNIQUE (name)
);


CREATE TABLE Subjects(
	subjectId INT NOT NULL AUTO_INCREMENT,
	degreeId INT NOT NULL,
	name VARCHAR(100) NOT NULL,
	acronym VARCHAR(8) NOT NULL,
	credits INT NOT NULL,
	year INT NOT NULL,
	type ENUM('Formación Básica', 'Optativa', 'Obligatoria') NOT NULL,
	PRIMARY KEY (subjectId),
	FOREIGN KEY (degreeId) REFERENCES Degrees (degreeId),
	CONSTRAINT uniqueSubjectName UNIQUE (name),
	CONSTRAINT uniqueSubjectAcronym UNIQUE (acronym),
	CONSTRAINT negativeSubjectCredits CHECK (credits > 0),
	CONSTRAINT invalidSubjectCourse CHECK (year >= 1 AND year <= 5)
); 

CREATE TABLE Groups(
	groupId INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(30) NOT NULL,
	activity VARCHAR(20) NOT NULL,
	year INT NOT NULL,
	subjectId INT NOT NULL,
	PRIMARY KEY (groupId),
	FOREIGN KEY (subjectId) REFERENCES Subjects (subjectId) ON DELETE CASCADE,
	CONSTRAINT repeatedGroup UNIQUE (name, year, subjectId),
	CONSTRAINT negativeGroupYear CHECK (year > 0),
	CONSTRAINT invalidGroupActivity CHECK (activity IN ('Teoría','Laboratorio'))
);

CREATE TABLE Students(
	studentId INT NOT NULL AUTO_INCREMENT,
	accessMethod VARCHAR(30) NOT NULL,
	dni CHAR(9) NOT NULL,
	firstName VARCHAR(100) NOT NULL,
	surname VARCHAR(100) NOT NULL,
	birthDate DATE NOT NULL,
	email VARCHAR(250) NOT NULL,
	password VARCHAR(250) NOT NULL,
	PRIMARY KEY (studentId),
	CONSTRAINT uniqueStudentDni UNIQUE (dni),
	CONSTRAINT uniqueStudentEmail UNIQUE (email),	
	CONSTRAINT invalidStudentAccessMethod CHECK (accessMethod IN
	('Selectividad','Ciclo','Mayor','Titulado Extranjero'))
);

CREATE TABLE GroupsStudents(
	groupStudentId INT NOT NULL AUTO_INCREMENT,
	groupId INT NOT NULL,
	studentId INT NOT NULL,
	PRIMARY KEY (groupStudentId),
	FOREIGN KEY (groupId) REFERENCES Groups (groupId),
	FOREIGN KEY (studentId) REFERENCES Students (studentId),
	UNIQUE (groupId, studentId)
);
CREATE TABLE Grades(grades
	gradeId INT NOT NULL AUTO_INCREMENT,
	value DECIMAL(4,2) NOT NULL,
	gradeCall INT NOT NULL,
	withHonours BOOLEAN NOT NULL,
	studentId INT NOT NULL,
	groupId INT NOT NULL,
	PRIMARY KEY (gradeId),
	FOREIGN KEY (studentId) REFERENCES Students (studentId),
	FOREIGN KEY (groupId) REFERENCES Groups (groupId),
	CONSTRAINT invalidGradeValue CHECK (value >= 0 AND value <= 10),
	CONSTRAINT invalidGradeCall CHECK (gradeCall >= 1 AND gradeCall <= 3),
	CONSTRAINT RN_002_duplicatedCallGrade UNIQUE (gradeCall, studentId, groupId)
);







-- RF-002: Borrar las notas de un alumno con un DNI dado
DELIMITER //
CREATE OR REPLACE PROCEDURE procDeleteGrades(studentDni CHAR(9))
BEGIN
	DECLARE id INT;
	SET id = (SELECT studentId s FROM Students s WHERE s.dni=studentDni);
	DELETE FROM Grades WHERE studentId=id;
END //
DELIMITER ;

-- Llamamos al procedimiento 
CALL procDeleteGrades('12345678A');

-- RF 001 añadir la nota de un alumno en un grupo
DELIMITER //
CREATE OR REPLACE PROCEDURE procAnadirNota(
    p_studentDni CHAR(9),
    p_groupId INT,
    p_gradeValue DECIMAL(4,2),
    p_gradeCall INT,
    p_withHonours BOOLEAN
)
BEGIN
    -- Declarar la variable para guardar el ID del estudiante
    DECLARE v_studentId INT;
    
    -- 1. Encontrar el studentId basándonos en el DNI
    -- Hacemos referencia a la tabla Students
    SET v_studentId = (SELECT studentId FROM Students s WHERE s.dni = p_studentDni);
    
    -- 2. Insertar la nota en la tabla Grades
    -- Si ya existe una nota para ese alumno, grupo y convocatoria
    -- (basado en la restricción UNIQUE RN_002_duplicatedCallGrade),
    -- se actualiza el valor (value) y la matrícula de honor (withHonours).
    INSERT INTO Grades (value, gradeCall, withHonours, studentId, groupId)
    VALUES (p_gradeValue, p_gradeCall, p_withHonours, v_studentId, p_groupId)
    ON DUPLICATE KEY UPDATE
        value = p_gradeValue,
        withHonours = p_withHonours;
        
END //
DELIMITER ;
-- RF-007 obtener nota media de un alumno
DELIMITER //
CREATE OR REPLACE FUNCTION avgGrade(studentId INT) RETURNS DOUBLE
BEGIN
	DECLARE avgStudentGrade DOUBLE;
	SET avgStudentGrade = (SELECT AVG(value) FROM Grades
		WHERE Grades.studentId = studentId);
	RETURN avgStudentGrade;
END //
DELIMITER ;

SELECT avgGrade(2);


-- Triggers RN001 
DELIMITER //
CREATE OR REPLACE TRIGGER RN001_triggerWithHonours
BEFORE INSERT ON Grades
FOR EACH ROW
BEGIN
    IF (new.withHonours = 1 AND new.value < 9.0) THEN
        SIGNAL SQLSTATE '45000' SET message_text = 
        'You cannot insert a grade with honours whose value is less than 9';
    END IF;
END//
DELIMITER ;
