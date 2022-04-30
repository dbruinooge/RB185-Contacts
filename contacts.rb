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

def valid_phone_number?(area_code, number)
  area_code.digits.length == 3 && area_code !~ /\D/ &&
  number.digits.length == 7 && number !~ /\D/
end

def valid_street_address?(street, city, state, postal)
  street.length <= 100 && city.length <= 50 &&
  state.length == 2 && postal.length == 5 &&
  state !~ /[^a-zA-Z]/ && postal !~ /\D/
end

def valid_email_address?(email_address)
  email_address =~ URI::MailTo::EMAIL_REGEXP
end

def valid_person_name?(name)
  true
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
  if valid_person_name?(name)
    @storage.add_person(name)
    redirect "/index"
  else
    erb :add_person
  end
end

# Add phone number
post "/phone_number/add/:person_id" do
  person_id = params[:person_id].to_i
  area_code = params[:area_code].to_i
  number = params[:number].to_i
  type = params[:type]
  if valid_phone_number?(area_code, number)
    @storage.add_phone_number(area_code, number, type, person_id)
    redirect "/person/#{person_id}"
  else
    erb :add_phone_number
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
  if valid_street_address?(street, city, state, postal)
    @storage.add_street_address(street, city, state, postal, type, person_id)
    redirect "/person/#{person_id}"
  else
    erb :add_street_address
  end
end

# Add email address
post "/email_address/add/:person_id" do
  person_id = params[:person_id].to_i
  email = params[:email]
  type = params[:type]
  if valid_email_address?(email)
    @storage.add_email_address(email, type, person_id)
    redirect "/person/#{person_id}"
  else
    erb :add_email_address
  end
end

# Delete person
post "/person/delete/:person_id" do
  @storage.delete_person(params[:person_id])
  redirect "/index"
end

# Delete phone number
post "/person/:person_id/phone_number/:phone_id" do
  @storage.delete_phone_number(params[:phone_id])
  redirect "/person/#{params[:person_id]}"
end

# Delete street address
post "/person/:person_id/street_address/:street_id" do
  @storage.delete_street_address(params[:street_id])
  redirect "/person/#{params[:person_id]}"
end

# Delete email address
post "/person/:person_id/email_address/:email_id" do
  @storage.delete_email_address(params[:email_id])
  redirect "/person/#{params[:person_id]}"
end

