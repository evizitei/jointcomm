require 'rubygems'
require 'data_mapper'
require 'dm-postgres-adapter'
require 'dm-core'
require 'dm-timestamps'
require 'bcrypt'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/jointcomm_dev')

class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial, key: true
  property :username, String, length: (3..50)
  property :password, BCryptHash

  def authenticate(pw_attempt)
    return self.password == pw_attempt
  end
end

class Call
  include DataMapper::Resource

  property :id, Serial, key: true
  property :pickup, String
  property :dropoff, String
  property :phone, String
  property :price, String
  property :driver_id, Integer
  property :cleared_at, DateTime
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  def self.unassigned
    all(driver_id: nil)
  end

  def self.in_flight
    all(:driver_id.not => nil, :cleared_at => nil)
  end

  def driver
    Driver.get(self.driver_id)
  end
end

class Driver
  include DataMapper::Resource

  property :id, Serial, key: true
  property :name, String
  property :phone, String
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date
end

DataMapper.finalize
DataMapper.auto_upgrade!
