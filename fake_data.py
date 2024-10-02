import mysql.connector
import uuid
from faker import Faker
from dotenv import load_dotenv
import random
import os

# Load environment variables
load_dotenv()


# Connect to the MySQL database
connection = mysql.connector.connect(
    host='localhost',
    user='root',
    password='1234554321',
    database='pa2'
)

cursor = connection.cursor()
fake = Faker()

cursor.execute("SELECT * FROM teachers LIMIT 1;")
result = cursor.fetchone()
print(result)


# Insert 10,000 rows into teachers
print("Inserting into teachers...")
teacher_insert_query = """
    INSERT INTO teachers (teacher_id, teacher_name, teacher_surname, email, phone, address)
    VALUES (%s, %s, %s, %s, %s, %s)
"""
teacher_data = [
    (str(uuid.uuid4()), fake.first_name(), fake.last_name(), fake.email(), fake.phone_number(), fake.address())
    for _ in range(10000)
]
cursor.executemany(teacher_insert_query, teacher_data)
connection.commit()
print("Inserted into teachers.")



# Insert 30,000 rows into subjects
teachers_query = "SELECT * FROM teachers"
teachers = cursor.fetchall()


print("Inserting into subjects...")

subject_names = [
    'Mathematics', 'Physics', 'Chemistry', 'Biology', 'History', 'Geography',
    'English', 'Computer Science', 'Economics', 'Art', 'Physical Education'
]

subject_insert_query = """
    INSERT INTO subjects (subject_id, subject_name, teacher_id)
    VALUES (%s, %s, %s)
"""
subject_data = [
    (str(uuid.uuid4()), random.choice(subject_names), random.choice(teacher_data)[0])
    for _ in range(30000)
]
cursor.executemany(subject_insert_query, subject_data)
connection.commit()
print("Inserted into subjects.")



# Insert 50,000 rows into students
subjects_query = "SELECT * FROM subjects"
subjects = cursor.fetchall()


print("Inserting into students...")
student_insert_query = """
    INSERT INTO students (student_id, student_name, student_surname, subject_id)
    VALUES (%s, %s, %s, %s)
"""

student_data = [
    (str(uuid.uuid4()), fake.first_name(), fake.last_name(), random.choice(subject_data)[0])
    for _ in range(50000)
]


# Use chunks to avoid memory issues
chunk_size = 10000
for i in range(0, len(student_data), chunk_size):
    cursor.executemany(student_insert_query, student_data[i:i + chunk_size])
    connection.commit()
    print(f"Inserted {i + chunk_size} rows into students...")

print("Inserted into students.")


# Close the cursor and connection
cursor.close()
connection.close()

