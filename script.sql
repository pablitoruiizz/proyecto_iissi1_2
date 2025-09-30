DROP TABLE IF EXISTS Grades;
DROP TABLE IF EXISTS GroupsStudents;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Groups;
DROP TABLE IF EXISTS Subjects;
DROP TABLE IF EXISTS Degrees;


CREATE TABLE Degrees(
	degreeId INT AUTO_INCREMENT,
	name VARCHAR(60),
	years INT DEFAULT(4),
	PRIMARY KEY (degreeId)
);


CREATE TABLE Subjects(
	subjectId INT AUTO_INCREMENT,
	degreeId INT,
	name VARCHAR(100),
	acronym VARCHAR(8),
	credits INT,
	year INT,
	type VARCHAR(20),
	PRIMARY KEY (subjectId),
	FOREIGN KEY (degreeId) REFERENCES Degrees (degreeId)
); 

CREATE TABLE Groups(
	groupId INT AUTO_INCREMENT,
	name VARCHAR(30),
	activity VARCHAR(20),
	year INT,
	subjectId INT,
	PRIMARY KEY (groupId),
	FOREIGN KEY (subjectId) REFERENCES Subjects (subjectId)
);

CREATE TABLE Students(
	studentId INT AUTO_INCREMENT,
	accessMethod VARCHAR(30),
	dni CHAR(9),
	firstName VARCHAR(100),
	surname VARCHAR(100),
	birthDate DATE,
	email VARCHAR(250),
	password VARCHAR(250),
	PRIMARY KEY (studentId)
);

CREATE TABLE GroupsStudents(
	groupStudentId INT AUTO_INCREMENT,
	groupId INT,
	studentId INT,
	PRIMARY KEY (groupStudentId),
	FOREIGN KEY (groupId) REFERENCES Groups (groupId),
	FOREIGN KEY (studentId) REFERENCES Students (studentId)
);

CREATE TABLE Grades(
	gradeId INT AUTO_INCREMENT,
	value DECIMAL(4,2),
	gradeCall INT,
	withHonours BOOLEAN,
	studentId INT,
	groupId INT,
	PRIMARY KEY (gradeId),
	FOREIGN KEY (studentId) REFERENCES Students (studentId),
	FOREIGN KEY (groupId) REFERENCES Groups (groupId)
);

