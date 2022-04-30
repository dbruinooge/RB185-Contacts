require "pg"
require "pry"

class DatabasePersistence
  def initialize
    @db = PG.connect(dbname: "contacts")
  end

  def query(statement, *arguments)
    @db.exec_params(statement, arguments)
  end

  def find_all_persons
    sql = "SELECT * FROM persons"
    result = query(sql)
    result.map do |tuple|
      { person_id: tuple["person_id"], name: tuple["name"] }
    end
  end

  def find_person(person_id)
    sql = "SELECT * FROM persons WHERE person_id = $1"
    result = query(sql, person_id)
    tuple = result.first
    { person_id: tuple["person_id"], name: tuple["name"] }
  end

  def find_phone_numbers(person_id)
    sql = <<~SQL
      SELECT * FROM phone_numbers
      JOIN persons ON persons.person_id = phone_numbers.person_id
      WHERE phone_numbers.person_id = $1
    SQL
    result = query(sql, person_id)
    result.map do |tuple|
      {
        phone_id: tuple["phone_id"],
        area_code: tuple["area_code"],
        number: tuple["number"],
        type: tuple["type"]
      }
    end
  end

  def find_street_addresses(person_id)
    sql = <<~SQL
      SELECT * FROM street_addresses
      JOIN persons ON persons.person_id = street_addresses.person_id
      WHERE street_addresses.person_id = $1
    SQL
    result= query(sql, person_id)
    result.map do |tuple|
      {
        street_id: tuple["street_id"],
        street: capitalize_words(tuple["street"]),
        city: capitalize_words(tuple["city"]),
        state: tuple["state"].upcase,
        postal: tuple["postal"],
        type: tuple["type"]
      }
    end
  end

  def find_email_addresses(person_id)
    sql = <<~SQL
      SELECT * FROM email_addresses
      JOIN persons ON persons.person_id = email_addresses.person_id
      WHERE email_addresses.person_id = $1
    SQL
    result= query(sql, person_id)
    result.map do |tuple|
      {
        email_id: tuple["email_id"],
        email: tuple["email"],
        type: tuple["type"]
      }
    end
  end

  def add_phone_number(area_code, number, type, person_id)
    sql = <<~SQL
      INSERT INTO phone_numbers (area_code, number, "type", person_id)
      VALUES ($1, $2, $3, $4)
    SQL
    query(sql, area_code, number, type, person_id)
  end

  def add_street_address(street, city, state, postal, type, person_id)
    sql = <<~SQL
      INSERT INTO street_addresses (street, city, state, postal, type, person_id)
      VALUES ($1, $2, $3, $4, $5, $6)
    SQL
    query(sql, street, city, state, postal, type, person_id)
  end

  def add_email_address(email, type, person_id)
    sql = <<~SQL
      INSERT INTO email_addresses (email, type, person_id)
      VALUES ($1, $2, $3)
    SQL
    query(sql, email, type, person_id)
  end

  def add_person(name)
    sql = <<~SQL
      INSERT INTO persons (name)
      VALUES ($1)
    SQL
    query(sql, name)
  end

  def delete_phone_number(phone_id)
    sql = <<~SQL
      DELETE FROM phone_numbers
      WHERE phone_numbers.phone_id = $1
    SQL
    query(sql, phone_id)
  end

  def delete_street_address(street_id)
    sql = <<~SQL
      DELETE FROM street_addresses
      WHERE street_addresses.street_id = $1
    SQL
    query(sql, street_id)
  end

  def delete_email_address(email_id)
    sql = <<~SQL
      DELETE FROM email_addresses
      WHERE email_addresses.email_id = $1
    SQL
    query(sql, email_id)
  end

  def delete_person(person_id)
    sql = <<~SQL
      DELETE FROM persons
      WHERE persons.person_id = $1
    SQL
    query(sql, person_id)
  end

  private

  def capitalize_words(string)
    string.split.map { |string| string.capitalize }.join(" ")
  end
end