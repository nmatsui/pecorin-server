require 'json'

class SessionsController < ApplicationController

	before_filter :is_authenticated?, :except => [:create, :new, :failure]

	def create
		auth = request.env["omniauth.auth"]
		user = User.where(:facebook_id => auth['uid']).first
		if user
			user.update_with_omniauth(auth)
		else
			user = User.create_with_omniauth(auth)
		end
		session[:user_id] = user.id
		redirect_to :action => "success", :auth => user.pecorin_token
	end

	def success
		user = find_user_by_auth
		if user
			response = {:name => user.name, :facebook_id => user.facebook_id, :image_url => user.image_url}
			render :json => response.to_json, :status => :ok
		end
	end

	def failure
		render :text => "Authentication Failed", :status => :unauthorized
	end

	def new
		redirect_to "/auth/facebook"
	end

	def destroy
		user = find_user_by_auth
		user.pecorin_token = nil
		user.save!
		session[:user_id] = nil
		render :text => "Signed out", :status => :ok
	end
end
