enable :sessions 



get '/' do
  erb :"static/home"
end

get '/register' do
	@page = "register"
  erb :"static/register"
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



		redirect "/users/" + user.id.to_s  
	else
		flash[:error] = user.errors.full_messages #this is from validation
		redirect '/register'

		#what is flash: https://github.com/SFEley/sinatra-flash

		#user.errors #<ActiveModel::Errors:0x007fadf917ec48 @base=#<User id: nil, name: "fdsaf", email: "gmail.com", password_digest: "$2a$10$z8uWcSjX8/7tIBtygeHstuQz1NPtT1ssVYM1EBzkpoy...", created_at: nil, updated_at: nil>, @messages={:email=>["Email invalid"], :password=>["At least 8 characters required!"], :password_confirmation=>["doesn't match Password"]}, @details={:email=>[{:error=>:invalid, :value=>"gmail.com"}], :password=>[{:error=>:invalid, :value=>"fda"}], :password_confirmation=>[{:error=>:confirmation, :attribute=>"Password"}]}>

		#usser.errors.full_message => 
		# ["Email Email invalid", "Password At least 8 characters required!", "Password confirmation doesn't match Password"]
	end
end

get '/login' do
	@page = "login"
	erb :"static/login"
end

post '/login' do

	user = User.find_by(email: params[:user][:email])
	if user && user.authenticate(params[:user][:password])
		session[:id] = user.id
		redirect "/"
	else
		flash[:error] = 'Wrong email/password combo'
		#'Wrong email/password combo' will override the previous 'user.errors.full_message' in the 'flash[:error]'

		redirect '/login'
	end
end

get '/users/:id' do
	if logged_in? #if 'logged_in?' is not called, then someone from another computer can just type '/:name' and get your user profile 
		erb :'static/profile'
	else
		flash[:error] = 'You are not logged in'
		redirect '/login'
	end
end
#####
get '/users/:id/edit' do
	erb :'static/edit_user'
end

put '/users/:id' do
	current_user.update(params[:user])
	redirect to '/users/' + current_user.id.to_s
end

post '/logout' do
	session[:id] = nil
	redirect '/'
end

get '/questions/new' do 
	erb :"static/add_question"
end

get '/questions/:question_id' do
	@question = Question.find(params[:question_id]) 
	erb :"static/each_question"
end

post '/questions' do #when creating, always post to the root, like questions instead of questions/new 
	qn = Question.create(question_text: params[:question], user_id: current_user.id)
	redirect "/questions/" + qn.id.to_s 
end

get '/questions/:id/edit' do
	@question = Question.find(params[:id])
	erb :'static/edit_question'
end

put '/questions/:id' do
	question = Question.find(params[:id])
	question.update(params[:question])
	redirect to '/questions/' + question.id.to_s
end

get '/questions/:id/delete' do
	@question = Question.find(params[:id])
	erb :'static/delete_question'
end

delete '/questions/:id' do
	question = Question.find(params[:id])
	question.answers.each do |answer|
		answer.destroy
	end
	question.destroy
	erb :"static/profile"
end

post '/answers' do
	ans = Answer.create(answer_text: params[:answer], question_id: params[:question][:id], user_id: current_user.id)
	#(byebug) params
	#{"answer"=>"idk", "question"=>{"id"=>"3"}}
	redirect "/questions/" + ans.question_id.to_s 
end


get '/answers/:id/edit' do #id or question_id
	@answer = Answer.find(params[:id])
	erb :'static/edit_answer'
end

put '/answers/:id' do
	ans = Answer.find(params[:id])
	ans.update(params[:answer])
	redirect to '/questions/' + ans.question_id.to_s
end

get '/answers/:id/delete' do
	@answer = Answer.find(params[:id])
	erb :'static/delete_answer'
end

delete '/answers/:id' do
	answer = Answer.find(params[:id])
	answer.destroy
	erb :"static/profile"
end

########QuestionVote #############
post '/questions/:id/upvote' do

	vote = QuestionVote.find_by(question_id: params[:id], user_id: current_user.id)
	@question = Question.find(params[:id])

	if vote #check if question has been voted by user
		if vote.vote == 1 #Check if that vote is an upvote. the second 'vote' is the column name whereas the first 'vote' is an object
			@message = "You can only upvote once per question" ###BUG: this never appears!
			erb :"static/home"

		else #if vote is a downvote, change vote to upvote
			@message = "Your vote has been changed to upvote"
			vote.update(vote: 1) #'update' is an active record method, not a column name
			erb :"static/home"
		end

	else #if question has not been voted, create new vote
		@message = "Your vote has been casted"
		current_user.question_votes.create(question_id: params[:id], vote: 1)
		erb :"static/home"
	end
end



post '/questions/:id/downvote' do


	vote = QuestionVote.find_by(question_id: params[:id], user_id: current_user.id)
	@question = Question.find(params[:id])

	if vote 
		if vote.vote == 0 
			@message = "You can only downvote once per question"
			erb :"static/home"

		else
			@message = "Your vote has been changed to downvote"
			vote.update(vote: 0) 
			erb :"static/home"
		end

	else 
		@message = "Your vote has been casted"
		current_user.question_votes.create(question_id: params[:id], vote: 0)
		erb :"static/home"
	end
end

########AnswerVote #############
post '/questions/:question_id/answer/:answer_id/upvote' do

	vote = AnswerVote.find_by(answer_id: params[:answer_id], user_id: current_user.id)
	@question = Question.find(params[:question_id])

	if vote 
		if vote.vote == 1 
			@message = "You can only upvote once per answer"
			erb :"static/each_question"

		else 
			@message = "Your vote has been changed to upvote"
			vote.update(vote: 1) 
			erb :"static/each_question"
		end

	else 
		@message = "Your vote has been casted"
		current_user.answer_votes.create(answer_id: params[:answer_id], vote: 1)
		erb :"static/each_question"
	end
end

post '/questions/:question_id/answer/:answer_id/downvote' do


	vote = AnswerVote.find_by(answer_id: params[:answer_id], user_id: current_user.id)
	@question = Question.find(params[:question_id])

	if vote 
		if vote.vote == 0
			@message = "You can only downvote once per answer"
			erb :"static/each_question"

		else 
			@message = "Your vote has been changed to downvote"
			vote.update(vote: 0) 
			erb :"static/each_question"
		end

	else 
		@message = "Your vote has been casted"
		current_user.answer_votes.create(answer_id: params[:answer_id], vote: 0)
		erb :"static/each_question"
	end
end
















































































