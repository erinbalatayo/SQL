# In this file, I answer a series of questions provided from https://www.sql-practice.com/
# I analyzed a database called hospital.db, which contains tables related to patient information, admissions, doctor information, and province names. 

# 1. Show how many patients have a birth_date with 2010 as the birth year.

SELECT COUNT(*) AS total_patients
from patients
WHERE YEAR(birth_date)=2010;

# 2. Show the first_name, last_name, and height of the patient with the greatest height.

SELECT first_name, last_name, height
from patients
ORDER BY height DESc
lIMIT 1;

# 3. Show all columns for patients who have one of the following patient_ids: 1,45,534,879,1000

SELECT *
FROM patients
WHERE patient_id IN (1,45,534,879,1000);

# 4. Show the total number of admissions

SELECT COUNT(*)
FROM admissions;

# 5. Show all the columns from admissions where the patient was admitted and discharged on the same day.

SELECT *
FROM admissions
WHERE admission_date=discharge_date; 


# 6. Show the patient id and the total number of admissions for patient_id 579.

SELECT patient_id, COUNT(admission_date) AS total_admissions
FROM admissions
WHERE patient_id=579;


# 7. Based on the cities that our patients live in, show unique cities that are in province_id 'NS'?

SELECT DISTINCT city
FROM patients
WHERE province_id='NS';

# 8. Write a query to find the first_name, last name and birth date of patients who has height greater than 160 and weight greater than 70

SELECT first_name, last_name, birth_date
FROM patients
WHERE height > 160 AND weight > 70;


# 9. Write a query to find list of patients first_name, last_name, and allergies from Hamilton where allergies are not null

SELECT first_name, last_name, allergies
FROM patients
WHERE city = "Hamilton" AND allergies IS NOT NULL; 

# 10. Based on cities where our patient lives in, write a query to display the list of unique city starting with a vowel (a, e, i, o, u). Show the result order in ascending by city

SELECT DISTINCT city
FROM patients
WHERE city LIKE 'A%' OR city LIKE 'E%' OR city LIKE 'I%' OR city LIKE 'O%' OR city LIKE 'U%'
order by city;

# 11. Show unique birth years from patients and order them by ascending.

SELECT DISTINCT YEAR(birth_date) AS birth_year
FROM patients
ORDER BY YEAR(birth_date);

# 12. Show unique first names from the patients table which only occurs once in the list.
# For example, if two or more people are named 'John' in the first_name column then don't include their name in the output list. If only 1 person is named 'Leo' then include them in the output.

SELECT distinct first_name
FROM patients
GROUP BY first_name
HAVING count(first_name)=1;

# 13. Show patient_id and first_name from patients where their first_name start and ends with 's' and is at least 6 characters long.

SELECT patient_id, first_name
FROM patients
WHERE first_name LIKE 'S%s' AND length(first_name)>=6;

# 14. Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'.
# Primary diagnosis is stored in the admissions table.

SELECT patients.patient_id, first_name, last_name
FROM patients
JOIN admissions
ON patients.patient_id=admissions.patient_id
WHERE  diagnosis='Dementia';

# 15. Display every patient's first_name.
# Order the list by the length of each name and then by alphbetically

SELECT first_name
FROM patients
ORDER BY LENGTH(first_name), first_name;

# 16. Show the total amount of male patients and the total amount of female patients in the patients table.
# Display the two results in the same row.

SELECT 
  SUM(Gender = 'M') as male_count, 
  SUM(Gender = 'F') AS female_count
FROM patients


# 17. Show first and last name, allergies from patients which have allergies to either 'Penicillin' or 'Morphine'. Show results ordered ascending by allergies then by first_name then by last_name.

SELECT first_name, last_name, allergies
FROM patients
WHERE allergies IN ('Penicillin', 'Morphine')
ORDER BY allergies, first_name, last_name;

# 18. Show patient_id, diagnosis from admissions. Find patients admitted multiple times for the same diagnosis.

SELECT patient_id, diagnosis
FROM admissions
GROUP BY patient_id, diagnosis
HAVING COUNT(*) > 1;

# 19. Show the city and the total number of patients in the city.
# Order from most to least patients and then by city name ascending.

SELECT city, COUNT(*) AS total_patients
FROM patients
GROUP by city
ORDER BY count(*) DESC, city ASC;

# 20. Show first name, last name and role of every person that is either patient or doctor.
# The roles are either "Patient" or "Doctor"

SELECT first_name, last_name, 'Patient' AS role
FROM patients

UNION ALL

SELECT first_name, last_name, 'Doctor' AS role
FROM doctors;

# 21. Show all allergies ordered by popularity. Remove NULL values from query.

SELECT allergies, COUNT(*) AS num_allergies
FROM patients
WHERE allergies IS NOT NULL
GROUP BY allergies
ORDER BY COUNT(*) desc;

# 22. Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. Sort the list starting from the earliest birth_date.

SELECT first_name, last_name, birth_date
FROM patients
WHERE YEAR(birth_date) LIKE '197%'
ORDER BY birth_date;

# 23. We want to display each patient's full name in a single column. Their last_name in all upper letters must appear first, then first_name in all lower case letters. Separate the last_name and first_name with a comma. Order the list by the first_name in decending order
# EX: SMITH,jane

SELECT CONCAT(UPPER(last_name), ',', LOWER(first_name)) AS full_name
FROM patients
ORDER BY first_name DESC;

# 24. Show the province_id(s), sum of height; where the total sum of its patient's height is greater than or equal to 7,000.

SELECT province_id, SUM(height) AS sum_height 
FROM patients
GROUP BY province_id
HAVING SUM(height)>=7000;

# 25. Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'

SELECT MAX(weight)-MIN(weight) AS weight_difference
FROM patients
WHERE last_name='Maroni';

# 26. Show all of the days of the month (1-31) and how many admission_dates occurred on that day. Sort by the day with most admissions to least admissions.

SELECT DAY(admission_date) AS date, COUNT(*) AS num_admissions
FROM admissions
GROUP BY DAY(admission_date) 
ORDER BY COUNT(*) DESC;

# 27. Show all columns for patient_id 542's most recent admission_date.

SELECT *
FROM admissions
WHERE patient_id=542
ORDER BY admission_date DESC
LIMIT 1;

# 28. Show patient_id, attending_doctor_id, and diagnosis for admissions that match one of the two criteria:
-- 1. patient_id is an odd number and attending_doctor_id is either 1, 5, or 19.
-- 2. attending_doctor_id contains a 2 and the length of patient_id is 3 characters.

SELECT patient_id, attending_doctor_id, diagnosis
FROM admissions
WHERE 
	(patient_id % 2 = 1 AND attending_doctor_id iN (1,5,19))
  OR
  (attending_doctor_id LIKE '%2%' AND LENGTH(patient_id)=3);

# 29. Show first_name, last_name, and the total number of admissions attended for each doctor.
# Every admission has been attended by a doctor.

SELECT first_name, last_name, COUNT(attending_doctor_id) AS num_admissions
FROM doctors d
JOIN admissions a
ON d.doctor_id=a.attending_doctor_id
GROUP BY attending_doctor_id;

# 30. For each doctor, display their id, full name, and the first and last admission date they attended.

SELECT
	doctor_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    MIN(admission_date) AS first_admission,
    MAX(admission_date) AS last_admission
FROM doctors d
	JOIN admissions a
	ON d.doctor_id=a.attending_doctor_id
GROUP BY doctor_id; 

# 31. Display the total amount of patients for each province. Order by descending.

SELECT
	province_name,
  COUNT(patient_id) AS total_patients
FROM province_names PN
	JOIN patients P
    ON PN.province_id=P.province_id
GROUP BY province_name
ORDER BY COUNT(patient_id) DESC;

# 32. For every admission, display the patient's full name, their admission diagnosis, and their doctor's full name who diagnosed their problem.

SELECT
	CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
  diagnosis,
  CONCAT(d.first_name, ' ', d.last_name) AS doctors_name
FROM patients p
	JOIN admissions a
    	ON p.patient_id=a.patient_id
  JOIN doctors d
    	ON a.attending_doctor_id=d.doctor_id;

# 33. display the number of duplicate patients based on their first_name and last_name.

SELECT first_name, last_name, COUNT(*) AS num_duplicate_names
FROM patients
GROUP BY first_name, last_name
HAVING COUNT(*) > 1;

/* 34. Display patient's full name,
height in the units feet rounded to 1 decimal,
weight in the unit pounds rounded to 0 decimals,
birth_date,
gender non abbreviated.

Convert CM to feet by dividing by 30.48.
Convert KG to pounds by multiplying by 2.205. */

SELECT 
	CONCAT(first_name, ' ' , last_name) AS full_name,
    ROUND((height/30.48),1) AS height_ft,
    ROUND((weight*2.205),0) AS weight_lbs,
    birth_date,
    CASE
    	WHEN gender='M' THEN 'male'
        WHEN gender='F' THEN 'female'
        ELSE 'Unknown'
    END AS full_gender
FROM patients;

/* #35. Show all of the patients grouped into weight groups.
Show the total amount of patients in each weight group.
Order the list by the weight group decending.

For example, if they weight 100 to 109 they are placed in the 100 weight group, 110-119 = 110 weight group, etc. */

SELECT
	FLOOR(weight/10) * 10 AS weight_group,
    COUNT(*) AS total_patients 
FROM patients
GROUP BY weight_group
ORDER BY weight_group DESC;

/* #36. 
Show patient_id, weight, height, isObese from the patients table.
Display isObese as a boolean 0 or 1.
Obese is defined as weight(kg)/(height(m)2) >= 30.
weight is in units kg.
height is in units cm. */


