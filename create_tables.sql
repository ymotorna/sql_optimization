create database pa2

use pa2

CREATE TABLE teachers (
    teacher_id CHAR(36) PRIMARY KEY,
    teacher_name VARCHAR(255) NOT NULL,
    teacher_surname VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    address TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS subjects (
    subject_id CHAR(36) PRIMARY KEY,
    subject_name VARCHAR(255) NOT NULL,
    teacher_id char(36),
    foreign key (teacher_id) references teachers (teacher_id)
);

CREATE TABLE IF NOT EXISTS students (
    student_id CHAR(36) PRIMARY KEY,
    student_name varchar(100),
    student_surname varchar(100),
    subject_id CHAR(36),
    foreign key (subject_id) references subjects (subject_id)
);
