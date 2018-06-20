class DeploymentsController < ApplicationController
	include QuestionMapperHelper
	include UrlValidatorHelper
	include EncryptionHelper
	include TokenValidationHelper
	before_action :get_details

	def new
		@deployment = Deployment.new({user_id: current_user.id, project_id: params[:project_id], project_name: params[:project_name], commit_id: params[:commit_id], status: "Created" , job_name: params[:job_name]})
	end

	def create
		return if !params_valid?(params)
		git_diff_link = generate_diff_link(params)
		deployment = Deployment.create!(user_id: current_user.id,project_id: params[:project_id], project_name: params[:project_name], commit_id: params[:commit_id], status: "CheckList Filled" ,diff_link: git_diff_link, checklist: params[:deployments].to_json,job_name: params[:job_name], reviewer_id: User.where(:email => params[:deployments][:reviewer_email]).first.id )
		UserMailer.deployment_request_email(deployment).deliver
		deployment.update({status: "Pending Approval"})
		redirect_to deployments_path
	end

	def show
		@deployment = Deployment.find(params[:id])
		get_question_mapper
	end

	def update
		deployment = Deployment.find(params[:id])
		return	if current_user.id != deployment.reviewer_id
		deployment.update(:status => params[:status])
		UserMailer.status_mail(deployment).deliver
		redirect_to deployment_url(:id => deployment.id)
	end

	def trigger_deployment
		deployment = Deployment.find(params[:id])
		return if current_user.id != deployment.user_id || deployment.status != "Approved"
		get_pipeline_and_job_id(deployment)
		redirect_to gitlab_pipeline_trigger_link(deployment)
	end

	private

	def get_pipeline_and_job_id(deployment)
		@last_pipeline_id = @gitlab_api_services.get_last_pipeline_id_of_commit(deployment.commit_id, deployment.project_id)
		@job_id = get_job_id_from_job_name(@gitlab_api_services.get_jobs_of_a_pipeline(deployment.project_id, @last_pipeline_id), deployment.job_name)
	end

	def params_valid?(params)
		if User.where(:email => params[:deployments][:reviewer_email]).blank? || current_user.id.to_s != params[:user_id]
			redirect_to new_deployment_path(user_id: current_user.id, project_name: params[:project_name], commit_id: params[:commit_id], diff_link: params[:diff_link], last_deployed_commit: params[:last_deployed_commit], project_id: params[:project_id])
			return false
		end
		return true
	end


	def get_job_id_from_job_name(jobs, job_name)
		jobs.each do |job|
			if job["name"] == job_name
				return job["id"]
			end
		end
	end

	def get_details
		@user = current_user
		@last_deployed_commit = params[:last_deployed_commit]
		@project_id = params[:project_id]
		get_gitlab_api_services(decrypt_access_token(current_user.gitlab_token))
	end

	def generate_diff_link(params)
		git_diff_link =  Figaro.env.diff_base_url + "/users/" + User.where(:email => params[:deployments][:reviewer_email]).first.id.to_s + "/projects/" + params[:project_id] + "/commits/" + params[:commit_id] + "?last_deployed_commit=" + params[:last_deployed_commit] + "&projaet_name=" + params[:project_name]
		git_diff_link
	end

	def gitlab_pipeline_trigger_link(deployment)
		Figaro.env.gitlab_base_url + @user.username + "/" + deployment.project_name + "/pipelines/" + @last_pipeline_id.to_s
	end



end
