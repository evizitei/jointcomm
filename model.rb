require 'rubygems'
require 'data_mapper'
require 'dm-postgres-adapter'
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

DataMapper.finalize
DataMapper.auto_upgrade!
