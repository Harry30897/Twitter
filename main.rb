require 'sinatra'
require 'data_mapper'

set :sessions ,true

DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/data.db")


class User
	include DataMapper::Resource
	property :email, String
	property :password, String
	property :id, Serial
end	

class Tweets
    include DataMapper::Resource
    property :id, Serial
    property :content, Text
    property :user_id, Integer
end

class Likes
	include DataMapper::Resource
	property :tweet_id, Serial
	property :user_id, Integer
end	

DataMapper.finalize
User.auto_upgrade!
Tweets.auto_upgrade!
Likes.auto_upgrade!

get '/' do
	erb :signin
end

get '/signup' do
	erb :signup
end


post '/signup' do
	email = params[:email]
	password = params[:password]
    user = User.all(:email=>email).first
    if user
    	redirect '/signup'
    else
    	user = User.new
    	user.email = params[:email]
    	user.password = params[:password]
    	user.save
    	session[:user_id] = user.id
    	#redirect '/temp'
    	redirect '/profile'
    end	
end


post '/signin' do
	email = params[:email]
	password = params[:password]
	user = User.all(:email=> email).first

	if user
		if user.password == password
			session[:user_id] = user.id
			#redirect '/temp'
			redirect '/profile'
		else 
			redirect '/'
		end
	else
		redirect '/signup'
	end	
	#redirect '/temp'
	redirect '/profile'
end

post '/signout' do
	session[:user_id] = nil
	redirect '/'
end	

get '/temp' do
	id = session[:user_id]
	user = User.get(id)
    erb :temp, locals: {:user=>user}
end	

get '/profile' do
	id = session[:user_id]
	user = User.get(id)
	tweets = Tweets.all
	users = User.all
	erb :table, locals: {:tweets=>tweets, :users=>users, :user=>user}
end


post '/Tweet' do
	tweet = Tweets.new
    tweet.content = params[:tweet]
    tweet.user_id = session[:user_id]
    tweet.save
    redirect '/profile'
 end   

post'/like' do
	user_id = session[:user_id]
	tweet_id = params[:tweet_id]
	like = Likes.all(:user_id=> user_id, :tweet_id=> tweet_id).first
	if like
		like.destroy
    else
    	like1 = Likes.new
    	like1.user_id = session[:user_id]
	    like1.tweet_id = params[:tweet_id]
	    like1.save
	end   
	redirect '/profile'
end	

post '/Delete' do
	user_id = session[:user_id]
	tweet_id = params[:tweet_id]
	tweet = Tweets.all(:user_id=> user_id, :id=> tweet_id).first
	if tweet
		tweet.destroy
	end
	redirect '/profile'	
end	