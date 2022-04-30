require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"

require_relative "lib/database_persistence.rb"

configure do
  enable :sessions
  set :session_secret, "secret"
  set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "lib/database_persistence.rb"
end

before do
  @storage = DatabasePersistence.new
end

def error_for_phone_number(area_code, number)
  if area_code.digits.length != 3
    "Area code must be 3 digits."
  elsif number.digits.length != 7
    "Phone number must be 7 digits."
  end
end

def error_for_street_address(street, city, state, postal)
  if street.length > 100
    "Street address must be no more than 100 characters."
  elsif city.length > 50
    "City name must be no more than 50 characters."
  elsif state.length != 2 || state =~ /[^a-zA-Z]/
    "State code must be 2 letters."
  elsif postal.length != 5 || postal =~ /\D/
    "Postal code must be 5 digits."
  end
end

def error_for_email_address(email_address)
  if email_address !~ URI::MailTo::EMAIL_REGEXP
    "Invalid format for email address."
  end
end

def error_for_person_name(name)
  if name.length > 100
    "Person's name must be no more than 100 characters."
  end
end

helpers do
  def display_phone_number(num)
    "(#{num[:area_code]}) #{num[:number][0..2]}-#{num[:number][3..6]} "\
    "(#{num[:type]})"
  end

  def display_street_address(address)
    "#{address[:street]}, #{address[:city]}, #{address[:state]}, "\
    "#{address[:postal]} (#{address[:type]})"
  end

  def display_email_address(address)
    "#{address[:email]} (#{address[:type]})"
  end
end

get "/" do
  redirect "/index"
end

# Display all persons
get "/index" do
  @persons = @storage.find_all_persons
  erb :index
end


# Display form to add person
get "/person/add" do
  erb :add_person
end

# Display contact info for one person
get "/person/:person_id" do
  person_id = params[:person_id].to_i
  @person = @storage.find_person(person_id)
  @phone_numbers = @storage.find_phone_numbers(person_id)
  @street_addresses = @storage.find_street_addresses(person_id)
  @email_addresses = @storage.find_email_addresses(person_id)
  erb :person
end

# Display form to add phone number
get "/phone_number/add/:person_id" do
 erb :add_phone_number
end

# Display form to add street address
get "/street_address/add/:person_id" do
  erb :add_street_address
end

# Display form to add email address
get "/email_address/add/:person_id" do
  erb :add_email_address
end

# Add person
post "/person/add" do
  name = params[:name]
  error = error_for_person_name(name)
  if error
    session[:error] = error
    erb :add_person
  else
    @storage.add_person(name)
    session[:success] = "The person has been added."
    redirect "/index"
  end
end

# Add phone number
post "/phone_number/add/:person_id" do
  person_id = params[:person_id].to_i
  area_code = params[:area_code].to_i
  number = params[:number].to_i
  type = params[:type]
  error = error_for_phone_number(area_code, number)
  if error
    session[:error] = error
    erb :add_phone_number
  else
    @storage.add_phone_number(area_code, number, type, person_id)
    session[:success] = "The phone number has been added."
    redirect "/person/#{person_id}"
  end
end

# Add street address
post "/street_address/add/:person_id" do
  person_id = params[:person_id].to_i
  street = params[:street]
  city = params[:city]
  state = params[:state]
  postal = params[:postal]
  type = params[:type]
  error = error_for_street_address(street, city, state, postal)
  if error
    session[:error] = error
    erb :add_street_address
  else
    @storage.add_street_address(street, city, state, postal, type, person_id)
    session[:success] = "The street address has been added."
    redirect "/person/#{person_id}"
  end
end

# Add email address
post "/email_address/add/:person_id" do
  person_id = params[:person_id].to_i
  email = params[:email]
  type = params[:type]
  error = error_for_email_address(email)
  if error
    session[:error] = error
    erb :add_email_address
  else
    @storage.add_email_address(email, type, person_id)
    session[:success] = "The email address has been added."
    redirect "/person/#{person_id}"
  end
end

# Delete person
post "/person/delete/:person_id" do
  @storage.delete_person(params[:person_id])
  session[:success] = "The person has been deleted."
  redirect "/index"
end

# Delete phone number
post "/person/:person_id/phone_number/:phone_id" do
  @storage.delete_phone_number(params[:phone_id])
  session[:success] = "The phone number has been deleted."
  redirect "/person/#{params[:person_id]}"
end

# Delete street address
post "/person/:person_id/street_address/:street_id" do
  @storage.delete_street_address(params[:street_id])
  session[:success] = "The street address has been deleted."
  redirect "/person/#{params[:person_id]}"
end

# Delete email address
post "/person/:person_id/email_address/:email_id" do
  @storage.delete_email_address(params[:email_id])
  session[:success] = "The email address has been deleted."
  redirect "/person/#{params[:person_id]}"
end

