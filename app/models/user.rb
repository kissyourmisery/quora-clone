# http://localhost:9393/

require 'bcrypt'

class User < ActiveRecord::Base

has_many :questions
has_many :answers
has_many :question_votes
has_many :answer_votes

validates :email, uniqueness: {message: "already registered!"}
validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "invalid"}
validates :password, :format => {:with => /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/, :message => "At least 8 characters required!"}



	has_secure_password 
	#it's a gem!! http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html


end


