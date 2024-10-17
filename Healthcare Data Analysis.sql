use healthcare;
-- retrive all table information
select * from patients;
select * from appointments;
select * from billing;
select * from doctors;
select * from prescriptions;

-- get all appointments for a specific patient 
select * from appointments
where patient_id=1;

-- retrieve all prescriptions for a specific appointment
select * from prescriptions
where appointment_id=1;

-- get billing infromation for a specfic appointment
select * from billing
where appointment_id=1;

select a.appointment_id,p.first_name as patient_first_name,p.last_name as patient_last_name,
d.first_name as doctor_first_name,d.last_name as doctor_last_name,
a.appointment_date,a.reason
from appointments a
join patients p on a.patient_id=p.patient_id
join doctors d on a.doctor_id=d.doctor_id;

-- list all appointments with billing status
select a.appointment_id,p.first_name as patient_first_name,p.last_name as patient_last_name,
d.first_name as doctor_first_name,d.last_name as doctor_last_name,
b.amount,b.payment_date,b.status
from appointments a
join patients p on a.patient_id=p.patient_id
join doctors d on a.doctor_id=d.doctor_id
join billing b on a.appointment_id=b.appointment_id;

-- find all paid billing
select * from billing
where status='paid';

-- calculate total amount billed and total paid amount
select
(select sum(amount)from billing) as total_billed,
(select sum(amount) from billing where status ='paid') as total_paid;

-- get the number of appointments by specialty
select d.specialty,count(a.appointment_id) as number_of_appointments
from appointments a
join doctors d on a.doctor_id=d.doctor_id
group by d.specialty;

-- find the most common reason for appointments
select reason,
count(*) as count
from appointments
group by reason
order by count desc;

-- list patients with their latest appointment date
select p.patient_id,p.first_name,p.last_name,max(a.appointment_date) as latest_appointment
from patients p
join appointments a on p.patient_id=a.patient_id
group by p.patient_id ,p.first_name,p.last_name;

-- list all doctors and the number of appointments they had
select d.doctor_id, d.first_name,d.last_name,count(a.appointment_id) as number_of_appointments
from doctors d
left join appointments a on d.doctor_id =a.doctor_id
group by d.doctor_id,d.first_name,d.last_name;

-- retrieve patients who had appointments in the last 30 days
select distinct p.*
from patients p
join appointments a on p.patient_id=a.patient_id
where a.appointment_date>=curdate()-interval 30 day;

-- find prescriptions associated with appointments that are pending  payment
select pr.prescription_id,pr.medication,pr.dosage,pr.instructions
from prescriptions pr
join appointments a on pr.appointment_id=a.appointment_id
join billing b on a.appointment_id=b.appointment_id
where b.status='pending';

-- detailed view of each patient, including their appointment and billing status
SELECT p.patient_id, p.first_name, p.last_name, p.dob, p.gender, p.address, p.contact_number,       
a.appointment_id, a.appointment_date, a.reason,       
b.amount, b.payment_date, b.status AS billing_status
FROM Patients p
LEFT JOIN Appointments a ON p.patient_id = a.patient_id
LEFT JOIN Billing b ON a.appointment_id = b.appointment_id
ORDER BY p.patient_id, a.appointment_date;

-- analyse patient demographics
select gender, count(*) as count
from patients
group by gender;

-- analyze the trend of appointments over months or years
select date_format(appointment_date,'%Y-%m') as month, count(*) as number_of_appointments
from appointments
group by month 
order by month;

-- yearly trend
select year(appointment_date) as year, count(*) as number_of_appointments
from appointments
group by year 
order by year;

-- identify the most frequently prescribeb medications and their total dosage
select medication, count(*) as frequency,sum(cast(substring_index(dosage,'',1)as unsigned)) as total_dosage
from prescriptions
group by medication
order by frequency desc;

-- average billing amount by number of appointments
select p.patient_id,count(a.appointment_id) as appointment_count,avg (b.amount) as avg_billing_amount
from patients p
left join appointments a on p.patient_id=a.patient_id
left join billing b on a.appointment_id=b.appointment_id
group by p.patient_id;

-- anyalze the correlation between appointment frequency and billing status
select p.patient_id,p.first_name,p.last_name,sum(b.amount) as total_billed
from patients p
join appointments a on p.patient_id=a.patient_id
join billing b on a.appointment_id=b.appointment_id
group by p.patient_id,p.first_name,p.last_name
order by total_billed desc
limit 10;

-- payment status over time
select date_format(payment_date,'%Y-%m') AS month,status,count(*) as count
from billing
group by month,status
order by month,status;

-- unpaid bills analysis
select p.patient_id,p.first_name,p.last_name,sum(b.amount) as total_unpaid
from patients p
join appointments a on p.patient_id=a.patient_id
join billing b on a.appointment_id=b.appointment_id
where b.status='pending'
group by p.patient_id,p.first_name,p.last_name
order by total_unpaid desc;

-- doctor performance metrics
select d.doctor_id,d.first_name,d.last_name,count(a.appointment_id) as number_of_appointments
from doctors d
left join appointments a on d.doctor_id=a.doctor_id
group by d.doctor_id,d.first_name,d.last_name;

-- day wise appointment counts
select appointment_date,count(*) as appointment_count
from appointments
group by appointment_date;

-- find patients with missing appointments
select p.patient_id,p.first_name,p.last_name
from patients p
left join appointments a on p.patient_id=a.patient_id
where a.appointment_id is null;

-- find apppointments without billing records
select a.appointment_id,a.patient_id,a.doctor_id,a.appointment_date
from appointments a
left join billing b on a.appointment_id=b.appointment_id
where b.billing_id is null;

-- find all appointments for doctor with id 1
select a.appointment_id,p.first_name as patient_first_name,p.last_name as patient_last_name,a.appointment_date,a.reason
from appointments a
join patients p on a.patient_id=p.patient_id
where a.doctor_id=1;

-- all prescription with payment status as pending
select p.medication,p.dosage,p.instructions,b.amount,b.payment_date,b.status
from prescriptions p
join appointments a on p.appointment_id=a.appointment_id
join billing b on a.appointment_id=b.appointment_id
where b.status='pending';

-- list all patients who had appointments in august
select distinct p.first_name,p.last_name,p.dob,p.gender,a.appointment_date
from patients p
join appointments a on p.patient_id=a.patient_id
where date_format(a.appointment_date,'%Y-%m')='2024-08';

-- list all doctors and their appointments in august till today
select d.first_name,d.last_name,appointment_date,p.first_name as patient_first_name,p.last_name as patient_last_name
from doctors d
join appointments a on d.doctor_id=a.doctor_id
join patients p on a.patient_id=p.patient_id
where a.appointment_date between '2024-08-01' and '2024-08-10';

-- get total amount billed per doctor
select d.first_name,d.last_name,d.specialty,sum(b.amount) as total_billed
from doctors d
join appointments a on d.doctor_id=a.doctor_id
join billing b on a.appointment_id=b.appointment_id
group by d.first_name,d.last_name,d.specialty
order by total_billed desc;