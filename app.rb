require 'pry'
require 'sinatra'
require_relative 'config/application'

set :bind, '0.0.0.0'  # bind to all interfaces

helpers do
  def current_user
    if @current_user.nil? && session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
      session[:user_id] = nil unless @current_user
    end
    @current_user
  end
end

get '/' do
  redirect '/meetups'
end

get '/auth/github/callback' do
  user = User.find_or_create_from_omniauth(env['omniauth.auth'])
  session[:user_id] = user.id
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/meetups' do
  @meetups = Meetup.all
  erb :'meetups/index'
end

get '/meetups/:meetup_id' do
  @meetup = Meetup.find_by(id: params[:meetup_id])
  erb :'meetups/show'
end

post '/meetups/:meetup_id' do
  @meetup = Meetup.find_by(id: params[:meetup_id])
  @users = @meetup.members
  if current_user && @users.exists?(current_user.id)
    flash.now[:notice] = "You're already a member of this meetup!"
  elsif current_user
    flash.now[:notice] = "Thanks for joining this meetup!"
    MeetupMembership.create(user_id: current_user.id, meetup_id: @meetup.id)
  else
    flash.now[:notice] = "You need to be signed in to join this meetup"
  end

  erb :'meetups/show'
end

get '/new' do
  if session[:user_id].nil?
    flash[:notice] = "Please sign in first."
    redirect '/'
  else
    erb :'meetups/new'
  end
end

post '/new' do
  if params[:name] == ""
    flash[:notice] = "Please enter a valid name"
    redirect '/new'
  elsif params[:location] == ""
    flash[:notice] = "Please enter a valid location"
    redirect '/new'
  elsif params[:description] == ""
    flash[:notice] = "Please enter a valid description"
    redirect '/new'
  else
    Meetup.create(id: params[:id], name: params[:name], location: params[:location], description: params[:description], creator: current_user.username)
    flash[:notice] = "Successfully Created New Meetup"
    redirect '/'
  end
end
