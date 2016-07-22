enable :sessions 


get '/' do
  erb :"static/home"
end

post '/register' do #'/register' action="/register" inside the form in the controller document 'home.erb'

	user = User.new(params[:user])
	#(byebug) params
	#{"user"=>{"name"=>"cheng", "email"=> "something@gmail.com", "password_digest"=>"$2a$10$z8uWcSjX8/7..."}}


	#to get your user password for example, just type in 'params[:user][:password]'. This is a nested hash



	#the nested hash is best practice so that each large hash can contain more information about the user when you key into the same form like below:

	#{"user"=>{"name"=>"cheng", "email"=> "something@gmail.com", "password_digest"=>"$2a$10$z8uWcSjX8/7..."}, "question"=>{"title"=>"why do we breathe"}}

	if user.save
		session[:id] = user.id 

		#need to assign session here because once we register successfully, it directs to each individual's profile. profile.erb says "<%= current_user.name %>". 'current_user' is a method from user.rb-helpers which contains 'session[:id]', hence have to define 'session[:id]' first.



		redirect "/#{user.name}" 
	else
		flash[:error] = user.errors.full_messages #this is from validation
		redirect '/'

		#what is flash: https://github.com/SFEley/sinatra-flash

		#user.errors #<ActiveModel::Errors:0x007fadf917ec48 @base=#<User id: nil, name: "fdsaf", email: "gmail.com", password_digest: "$2a$10$z8uWcSjX8/7tIBtygeHstuQz1NPtT1ssVYM1EBzkpoy...", created_at: nil, updated_at: nil>, @messages={:email=>["Email invalid"], :password=>["At least 8 characters required!"], :password_confirmation=>["doesn't match Password"]}, @details={:email=>[{:error=>:invalid, :value=>"gmail.com"}], :password=>[{:error=>:invalid, :value=>"fda"}], :password_confirmation=>[{:error=>:confirmation, :attribute=>"Password"}]}>

		#usser.errors.full_message => 
		# ["Email Email invalid", "Password At least 8 characters required!", "Password confirmation doesn't match Password"]
	end
end

get '/login' do
	erb :"static/login"
end

post '/login' do

	user = User.find_by(email: params[:user][:email])
	if user && user.authenticate(params[:user][:password])
		session[:id] = user.id
		redirect "/#{user.name}"
	else
		flash[:error] = 'Wrong email/password combo'
		#'Wrong email/password combo' will override the previous 'user.errors.full_message' in the 'flash[:error]'

		redirect '/'
	end
end

get '/:name' do
	if logged_in? #if 'logged_in?' is not called, then someone from another computer can just type '/:name' and get your user profile 
		erb :'static/profile'
	else
		flash[:error] = 'You are not logged in'
		redirect '/'
	end
end



post '/logout' do
	session[:id] = nil
	redirect '/'
end







































