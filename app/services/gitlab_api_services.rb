require 'httparty'
class GitlabApiServices
	def initialize(gitlab_token)
		@access_token = gitlab_token
		@base_url = "https://source.golabs.io/api/v4"
	end

  def check_api_for_valid_token?
    url = @base_url + "/users?private_token=" + @access_token
    response = HTTParty.get(url)
    if response.code == 200
      return true
    else false
    end
  end

	def get_user_details(username)
    url = @base_url + "/users?private_token=" + @access_token + "&username=" + username
    HTTParty.get(url)
	end

  def get_user_projects(gitlab_user_id, page_id)
    url = @base_url + "/projects?private_token=" + @access_token + "&per_page=10&page=" + page_id.to_s + "&owned=true&membership=true"
    HTTParty.get(url)
  end

	def get_project_details(gitlab_project_id)
		url = @base_url + "/projects/" + gitlab_project_id.to_s + "?private_token=" + @access_token + "&statistics=true"
		HTTParty.get(url)
	end

	def get_project_jobs(gitlab_project_id)
		url = @base_url + "/projects/" + gitlab_project_id.to_s + "/jobs?private_token=" + @access_token
		HTTParty.get(url)
	end

	def get_last_deployed_commit(gitlab_project_id)
		url = @base_url + "/projects/" + gitlab_project_id.to_s + "/deployments?private_token=" + @access_token
		HTTParty.get(url)[0]
	end

  def get_last_deployed_commit_dummy(gitlab_project_id)
    url = @base_url + "/projects/" + gitlab_project_id.to_s + "/repository/commits?private_token=" + @access_token
    response = HTTParty.get(url)
    response[response.length - 1]
  end

	def get_all_commits_after_last_deployed_commit(gitlab_project_id, time)
		url = @base_url + "/projects/" + gitlab_project_id.to_s + "/repository/commits?private_token=" + @access_token + "&since=" + time
		HTTParty.get(url)
	end

  def get_diff_of_two_commits(gitlab_project_id, source_commit, destination_commit)
    url = @base_url + "/projects/" + gitlab_project_id.to_s + "/repository/compare?private_token=" + @access_token + "&from=" + source_commit + "&to=" + destination_commit
    HTTParty.get(url)["diffs"]
  end

  def get_search_results(gitlab_user_id, searched_query)
    url = @base_url + "/projects?private_token=" + @access_token + "&owned=true&membership=true&search=" + searched_query + "&per_page=1000"
    search_results = HTTParty.get(url)
		search_results
  end

end
