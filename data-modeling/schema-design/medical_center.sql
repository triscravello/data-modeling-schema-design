--Schema Diagram for Medical Center--
--doctors(doctor_id PK, name, specialty)--
--patients(patient_id PK, name, date_of_birth)--
--visits(visit_id PK, doctor_id FK, patient_id FK, visit_date)--
--diseases(disease_id PK, name, description)--
--visit_disease(visit_id FK, disease_id FK)--

DROP DATABASE IF EXISTS medical_center;
CREATE DATABASE medical_center;
\c medical_center;

CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialty TEXT NOT NULL
);

CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL
);

CREATE TABLE visits (
    visit_id SERIAL PRIMARY KEY,
    doctor_id INTEGER REFERENCES doctors(doctor_id) ON DELETE SET NULL, -- Retain vists even if doctor is removed--,
    patient_id INTEGER REFERENCES patients(patient_id) ON DELETE CASCADE, -- Cascade delete to remove visits if patient is deleted--,
    visit_date DATE NOT NULL
);

CREATE TABLE diseases (
    disease_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT 
);

CREATE TABLE visit_disease(
    visit_id INTEGER REFERENCES visits(visit_id) ON DELETE CASCADE, -- Cascade delete to remove disease records if visit is deleted--, 
    disease_id INTEGER REFERENCES diseases(disease_id) ON DELETE CASCADE, -- Cascade delete to remove disease records if disease is deleted--,
    PRIMARY KEY (visit_id, disease_id), 
    diagnosis_notes TEXT,
    UNIQUE (visit_id, disease_id) -- Prevent duplicate disease entries for the same visit --
);

ALTER TABLE doctors ADD CONSTRAINT chk_specialty CHECK (LENGTH(specialty) > 0); -- Ensure specialty is not empty --
ALTER TABLE patients ADD CONSTRAINT chk_dob CHECK (date_of_birth <= CURRENT_DATE); -- Ensure date of birth is not in the future --

-- Indexes for performance optimization --
CREATE INDEX idx_visits_doctor ON visits(doctor_id);
CREATE INDEX idx_visits_patient ON visits(patient_id);
CREATE INDEX idx_visits_disease_visit ON visit_disease(visit_id);
CREATE INDEX idx_visits_disease_disease ON visit_disease(disease_id);
CREATE INDEX idx_doctors_name ON doctors(name); -- For searching by doctor name --
CREATE INDEX idx_patients_name ON patients(name); -- For searching by patient name --
CREATE INDEX idx_diseases_name ON diseases(name); -- For searching by disease name --
CREATE INDEX idx_visits_date ON visits(visit_date); -- For sorting/filtering by visit date --
CREATE INDEX idx_patients_dob ON patients(date_of_birth); -- For filtering by date of birth --
CREATE INDEX idx_doctors_specialty ON doctors(specialty); -- For filtering by specialty --
CREATE INDEX idx_visit_disease_notes ON visit_disease(diagnosis_notes); -- For searching by diagnosis notes--

ALTER TABLE visits
ADD COLUMN created_at TIMESTAMP DEFAULT NOW(),
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql; -- Trigger function to update updated_at column --

CREATE TRIGGER trg_update_visits_updated_at
BEFORE UPDATE ON visits
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); -- Trigger to call the function before updating a visit --

--Sample data insertion--
INSERT INTO doctors (name, specialty) VALUES ('Dr. Smith', 'Cardiology'), ('Dr. Jones', 'Neurology');
INSERT INTO patients (name, date_of_birth) VALUES ('John Doe', '1980-05-15'), ('Jane Roe', '1990-08-22');
INSERT INTO diseases (name, description) VALUES ('Flu', 'Influenza virus infection'), ('Diabetes', 'Chronic condition affecting blood sugar regulation');
INSERT INTO visits (doctor_id, patient_id, visit_date) VALUES (1, 1, '2023-10-01'), (2, 2, '2023-10-02');
INSERT INTO visit_disease (visit_id, disease_id, diagnosis_notes) VALUES (1, 1, 'Patient shows typical flu symptoms'), (2, 2, 'Patient diagnosed with Type 2 Diabetes');
