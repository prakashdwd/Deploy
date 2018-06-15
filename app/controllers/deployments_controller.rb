class DeploymentsController < ApplicationController
	include QuestionMapperHelper
	before_action :get_user_details

	def new
		git_diff_link = generate_diff_link(params)
		@deployment = Deployment.new({user_id: params[:user_id], project_name: params[:project_name], commit_id: params[:commit_id], status: "Created" ,diff_link: git_diff_link})
	end

	def create
		return if !reviewer_not_valid?
		deployment = Deployment.create!(user_id: params[:user_id], project_name: params[:project_name], commit_id: params[:commit_id], status: "CheckList Filled" ,diff_link: params[:diff_link], checklist: params[:deployments].to_json, reviewer_id: User.where(:email => params[:deployments][:reviewer_email]).first.id )
		UserMailer.sample_email(deployment).deliver
		deployment.update({status: "Pending Approval"})
		redirect_to deployments_path(:user_id => current_user.id)
	end

	def index
		@deployments = Deployment.where(:user_id => current_user.id)
	end

	def show
		@deployment = Deployment.find(params[:id])
		get_question_mapper
	end

	def update
		@deployment = Deployment.find(params[:id])
		@deployment.update(:status => params[:status]) if current_user.id == @deployment.reviewer_id
		redirect_to deployment_url(:id => @deployment.id)
	end

	private

	def reviewer_not_valid?
		if User.where(:email => params[:deployments][:reviewer_email]).blank?
			render 'deployments/new'
			return false
		end
		return true
	end

	def get_user_details
		@user = current_user
	end

	def generate_diff_link(params)
		git_diff_link =  "http://172.16.12.143:3000/users/"+ params[:user_id] + "/projects/" + params[:project_id] + "/commits/" + params[:commit_id] + "?last_deployed_commit=" + params[:last_deployed_commit] + "&project_name=" + params[:project_name]
		git_diff_link
	end

end
