CREATE TABLE `Programs` (
  `program_id` INT PRIMARY KEY,
  `program_code` VARCHAR(50),
  `program_name` VARCHAR(100),
  `program_degree` VARCHAR(100)
);

CREATE TABLE `Courses` (
  `courses_id` INT PRIMARY KEY,
  `course_grade` CHAR(2),
  `course_code` CHAR(50),
  `course_title` TEXT,
  `course_credits` INT,
  `course_points` DECIMAL,
  `course_gpa` DECIMAL,
  `CGPA` DECIMAL,
  `semester_id` INT,
  `comments` VARCHAR(50)
);

CREATE TABLE `Enrolled_Semester` (
  `semester_id` INT PRIMARY KEY,
  `student_id` INT,
  `semester` VARCHAR(50),
  `semester_earned` DECIMAL,
  `semester_attempted` DECIMAL,
  `semester_points` DECIMAL,
  `semester_gpa` DECIMAL
);

CREATE TABLE `EnrolledSemester_Crs` (
  `Crs_id` INT PRIMARY KEY,
  `semester_id` INT,
  `course_id` INT,
  `program_id` INT
);

CREATE TABLE `Student_information` (
  `student_id` INT PRIMARY KEY,
  `DOB` INT,
  `gender` CHAR(1),
  `program_start` VARCHAR(100),
  `programEnd` INT,
  `program_status` VARCHAR(100),
  `grad_date` INT,
  `district` TEXT,
  `city` TEXT,
  `ethnicity` TEXT,
  `feeder_id` INT,
  `program_id` INT
);

CREATE TABLE `Feeder` (
  `feeder_id` INT PRIMARY KEY,
  `feeder` TEXT
);

ALTER TABLE `EnrolledSemester_Crs` ADD FOREIGN KEY (`course_id`) REFERENCES `Courses` (`courses_id`);

ALTER TABLE `EnrolledSemester_Crs` ADD FOREIGN KEY (`semester_id`) REFERENCES `Enrolled_Semester` (`semester_id`);

ALTER TABLE `Enrolled_Semester` ADD FOREIGN KEY (`student_id`) REFERENCES `Student_information` (`student_id`);

ALTER TABLE `Student_information` ADD FOREIGN KEY (`feeder_id`) REFERENCES `Feeder` (`feeder_id`);

ALTER TABLE `EnrolledSemester_Crs` ADD FOREIGN KEY (`program_id`) REFERENCES `Programs` (`program_id`);

--QUARIES GIVEN BY SIR 

--Average time to graduation for BINT program:

SELECT 
    AVG(TO_DATE(grad_date, 'MM/DD/YYYY') - TO_DATE("programEnd", 'MM/DD/YYYY')) AS average_time_to_graduation
FROM "Student_information"
WHERE program_status = 'Graduated';

--Graduation rate for BINT program:

SELECT 
    COUNT(*) AS total_graduated,
    COUNT(*) / (SELECT COUNT(*) FROM "Student_information" WHERE program_status = 'Graduated') AS graduation_rate
FROM "Student_information"
WHERE program_status = 'Graduated';

--Ranking feeder institutions by admission rates:

SELECT 
    p.program_code, 
    COUNT(*) AS total_applications, 
    COUNT(*) / (SELECT COUNT(*) FROM "Student_information" WHERE program_status = 'Graduated') AS application_rate,
    COUNT(CASE WHEN program_status = 'Graduated' THEN 1 END) AS total_accepted,
    COUNT(CASE WHEN program_status = 'Graduated' THEN 1 END) / COUNT(*) AS acceptance_rate
FROM "Student_information" s
JOIN "Feeder" f ON s.feeder_id = f.feeder_id
JOIN "Programs" p ON s.program_id = p.program_id
WHERE s.program_status = 'Graduated'
GROUP BY p.program_code
ORDER BY acceptance_rate DESC;

--Overall acceptance rate for BINT program:

SELECT 
    COUNT(*) AS total_accepted,
    CASE WHEN (SELECT COUNT(*) FROM "Student_information" WHERE program_status = 'Graduated') = 0 
         THEN 0
         ELSE COUNT(*) / (SELECT COUNT(*) FROM "Student_information" WHERE program_status = 'Graduated') 
    END AS acceptance_rate
FROM "Student_information"
WHERE program_id = 13 AND program_status = 'Graduated';

--MY QUARIES 

--1. Pass and failure rates of Math and IT courses:

SELECT 
  course_title, 
  COUNT(*) AS TOTAL_STUDENTS, 
  SUM(CASE WHEN course_grade IN ('A', 'B', 'C', 'D') THEN 1 ELSE 0 END) AS PASS, 
  SUM(CASE WHEN course_grade IN ('F') THEN 1 ELSE 0 END) AS FAIL, 
  ROUND(100 * SUM(CASE WHEN course_grade IN ('A', 'B', 'C', 'D') THEN 1 ELSE 0 END) / COUNT(*), 2) AS PASS_RATE 
FROM 
  "Courses" 
WHERE 
 course_title IN ('PROGRAMMING LANGUAGES','ADVANCED COMPUTER ARCHITECTURE' ,'COMPUTER ORG. & ASSEMBLY LANG. PROG.','DISCRETE MATHEMATHICS','NETWORKING II','LINUX ADMINISTRATION','SENIOR INTERNSHIP','SOFTWARE ENGINEERING','NUMERICAL ANALYSIS','DIGITAL LOGIC & SIGNAL PROCESSING','DATABASE MGMT. SYS. II','P C REPAIR','','DATABASE MGMT. SYS. II','COMPILER CONSTRUCTION','SOFTWARE IN SOCIETY','COMPUTER TECHNOLOGY','DIFFERENTIAL CALCULUS','PROJECT','DISCRETE MATHEMATHICS','NETWORKING II','COMPUTER ARCHITECTURE','INTRODUCTION TO COMPUTER SYSTEMS','PROGRAMMING FOUNDATIONS','COMPUTER NETWORKING I','SOFTWARE ENGINEERING','DATABASE MGMT. SYS. II','NUMERICAL ANALYSIS','LINEAR PROGRAMMING.','SENIOR INTERNSHIP','OPERATING SYSTEMS','OBJECT ORIENTED SYSTEM DEV.','PRINCIPLES OF PROGRAMMING II','LINEAR PROGRAMMING.') 
GROUP BY 
  course_title;

--This query joins the EnrollmentCrs table and filters by Math and IT courses, groups by course title, and calculates the total number of students, pass and fail counts, and pass rate.


---2. Feeder institutions ranked by admission rates and grades:


SELECT 
  "Feeder".feeder, 
  COUNT(*) AS TOTAL_APPLICANTS, 
  SUM(CASE WHEN program_status = 'Graduated' THEN 1 ELSE 0 END) AS Graduated, 
  ROUND(100 * SUM(CASE WHEN program_status = 'Graduated' THEN 1 ELSE 0 END) / COUNT(*), 2) AS grad_rate, 
  AVG("Courses"."CGPA") AS AVG_CGPA
FROM 
  "Student_information"
  INNER JOIN "Feeder" ON "Student_information".feeder_id = "Feeder".feeder_id
  INNER JOIN "EnrolledSemester_Crs" ON "Student_information".student_id = "Student_information".student_id
  INNER JOIN "Programs" ON "EnrolledSemester_Crs".program_id = "Programs".program_id
  INNER JOIN "Courses" ON "EnrolledSemester_Crs"."Crs_id" = "Courses".course_id
WHERE 
  "Programs".program_code IN ('AINT', 'BINT') 
GROUP BY 
  "Feeder".feeder

ORDER BY 
  grad_rate DESC, 
  AVG_CGPA DESC;


--This query joins the EnrollmentSem and Feeder tables, filters by AINT and BINT programs, groups by feeder institution, and calculates the total number of applicants, accepted students, acceptance rate, and average CGPA. The results are sorted by acceptance rate and then by average CGPA in descending order.



--3. Overall acceptance rates into BINT programs:

SELECT 
  COUNT(*) AS TOTAL_APPLICANTS, 
  SUM(CASE WHEN program_status = 'Graduated' THEN 1 ELSE 0 END) AS Graduated, 
  ROUND(100 * SUM(CASE WHEN program_status = 'Graduated' THEN 1 ELSE 0 END) / COUNT(*), 2) AS grad_rate
FROM 
  "Student_information" 
  INNER JOIN "Programs" ON "Student_information".program_id = "Programs".program_id
WHERE 
    "Programs".program_code = 'BINT';

