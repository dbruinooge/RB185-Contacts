CREATE TYPE phone_number_type AS ENUM ('home', 'work', 'mobile');
CREATE TYPE street_address_type AS ENUM ('home', 'work');
CREATE TYPE email_address_type AS ENUM ('personal', 'work');

CREATE TABLE persons (
  person_id serial PRIMARY KEY,
  name varchar(100) UNIQUE NOT NULL
);

CREATE TABLE street_addresses (
  street_id serial PRIMARY KEY,
  street varchar(100) NOT NULL,
  city varchar(50) NOT NULL,
  state char(2) NOT NULL,
  postal integer NOT NULL CHECK (LENGTH(postal::text) = 5),
  "type" street_address_type NOT NULL,
  person_id integer NOT NULL REFERENCES persons (person_id) ON DELETE CASCADE
);

CREATE TABLE phone_numbers (
  phone_id serial PRIMARY KEY,
  area_code integer NOT NULL CHECK (LENGTH(area_code::text) = 3),
  number integer NOT NULL CHECK (LENGTH(number::text) = 7),
  "type" phone_number_type NOT NULL,
  person_id integer NOT NULL REFERENCES persons (person_id) ON DELETE CASCADE
);

CREATE TABLE email_addresses (
  email_id serial PRIMARY KEY,
  email varchar(100) NOT NULL,
  "type" email_address_type NOT NULL,
  person_id integer NOT NULL REFERENCES persons (person_id) ON DELETE CASCADE
);

INSERT INTO persons (name) VALUES
  ('Derek'),
  ('Jiyeon'),
  ('Mina'),
  ('Sejun')
;

INSERT INTO street_addresses (street, city, state, postal, "type", person_id)
  VALUES
  ('123 Main st', 'peabody', 'mA', 12345, 'home', 1),
  ('5566 Nowhere ln', 'cHicago', 'Il', 33125, 'work', 1)
;

INSERT INTO phone_numbers (area_code, number, "type", person_id) VALUES
  (555, 1234567, 'home', 1),
  (444, 7654321, 'work', 1)
;

INSERT INTO email_addresses (email, "type", person_id) VALUES
  ('john.doe@yahoo.com', 'personal', 1),
  ('importantperson@importantcompany.com', 'work', 1)
;
