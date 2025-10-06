--Schema Diagram for Medical Center--
--doctors(doctor_id PK, name, specialty)--
--patients(patient_id PK, name, date_of_birth)--
--visits(visit_id PK, doctor_id FK, patient_id FK, visit_date)--
--diseases(disease_id PK, name, description)--
--visit_disease(visit_id FK, disease_id FK)--

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
    doctor_id INTEGER REFERENCES doctors(doctor_id),
    patient_id INTEGER REFERENCES patients(patient_id),
    visit_date DATE NOT NULL
);

CREATE TABLE diseases (
    disease_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT 
);

CREATE TABLE visit_disease(
    visit_id SERIAL PRIMARY KEY,
    disease_id INTEGER REFERENCES diseases(id),
    PRIMARY KEY (visit_id, disease_id)
);
