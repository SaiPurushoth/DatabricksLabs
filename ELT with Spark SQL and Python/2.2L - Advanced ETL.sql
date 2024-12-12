-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC ## Lab: Advanced ETL

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Run the following cell to setup the lab environment 

-- COMMAND ----------

-- MAGIC %run ../Includes/Setup-Lab

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### Q1- Interacting with JSON data
-- MAGIC
-- MAGIC Review the nested data structures of the **profile** column in the **students** table created in the previous lab

-- COMMAND ----------

SELECT email, profile
FROM students

-- COMMAND ----------

DESCRIBE students

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC Use the appropriate syntax to access the **last_name** and **city** information from the **profile** column

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW parsed_students AS (
SELECT email, from_json(profile, schema_of_json('
{"first_name":"Susana","last_name":"Gonnely","gender":"Female","address":{"street":"760 Express Court","city":"Obrenovac","country":"Serbia"}}')) AS profile_struct
  FROM students );


  select * from parsed_students;

-- COMMAND ----------

SELECT email, profile_struct.last_name AS student_surname, profile_struct.address.city AS student_city
FROM parsed_students;

-- COMMAND ----------

-- Altenative Approach
SELECT email, profile:last_name AS student_surname, profile:address:city AS student_city
FROM students


-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### Q2- Higher Order Functions
-- MAGIC
-- MAGIC Review the array column **courses** in the **enrollments** table created in the previous lab

-- COMMAND ----------

SELECT enroll_id, courses 
FROM enrollments

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Filter this array column to keep only course elements having subtotal greater than 40

-- COMMAND ----------

SELECT
  enroll_id,
  courses,
  filter(courses, i ->i.subtotal > 40 ) AS large_totals
FROM enrollments

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### Q3- SQL UDFs

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC Define a UDF function named **get_letter_grade** that takes one parameter named **gpa** of type DOUBLE. It returns the corresponding letter grade as indicated in the following table:
-- MAGIC
-- MAGIC
-- MAGIC
-- MAGIC | GPA (4.0 Scale) | Grade Letter |
-- MAGIC |---------|-----------|
-- MAGIC |    3.50 - 4.0    |    A   |
-- MAGIC |    2.75 - 3.44    |    B  |
-- MAGIC |    2.0 - 2.74    |    C   |
-- MAGIC |    0.0 - 1.99    |    F   |

-- COMMAND ----------

create or replace function get_letter_grade(gpa double)
returns string
return case when gpa >= 3.50 then 'A'
            when gpa >= 2.75 then 'B'
            when gpa >= 2.0 then 'C'
            else 'F' 
        end;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC Let's apply the above UDF on the **students** table created in the previous lab
-- MAGIC
-- MAGIC Fill in the below query to call the defined UDF on the **gpa** column 

-- COMMAND ----------

SELECT student_id, gpa, get_letter_grade(gpa) as letter_grade
FROM students
