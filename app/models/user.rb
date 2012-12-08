class User < ActiveRecord::Base
  acts_as_authentic
  paginates_per 10
  default_scope order(:login)  
  attr_accessible :login, :givenname, :surname, :email, :password, :password_confirmation
end
