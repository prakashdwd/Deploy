require 'rails_helper'
RSpec.describe GitlabApiServices  do
  include EncryptionHelper
  fixtures :users

  context "check api for valid token" do
    it "Should return TRUE when token is Valid'" do
      VCR.use_cassette("valid_gitlab_token") do
        actual = GitlabApiServices.new(decrypt_access_token(users(:one).gitlab_token)).check_api_for_valid_token?
        expect(actual).to eq true
      end
    end

    it "Should return FALSE when token is Invalid'" do
      VCR.use_cassette("invalid_gitlab_token") do
        actual = GitlabApiServices.new(decrypt_access_token(users(:two).gitlab_token)).check_api_for_valid_token?
        expect(actual).to eq false
      end
    end
  end

  context "check api for user details" do
    it "Should contain the name of the user'" do
      VCR.use_cassette("user_details") do
        actual = GitlabApiServices.new(decrypt_access_token(users(:one).gitlab_token)).get_user_details(users(:one).username)
        expect(actual.first["name"]).to eq "Ritik Verma"
      end
    end
  end

  context "check api for number of pages" do
    it "Should return 1 when there are 2 projects" do
      VCR.use_cassette("projects") do
        actual = GitlabApiServices.new(decrypt_access_token(users(:one).gitlab_token)).get_number_of_pages(users(:one).gitlab_user_id)
        expect(actual).to eq 1
      end
    end
  end

  context "check api for project details" do
    it "Should return 2 projects" do
      VCR.use_cassette("paginated_projects") do
        actual = GitlabApiServices.new(decrypt_access_token(users(:one).gitlab_token)).get_user_projects(users(:one).gitlab_user_id, 1)
        expect(actual.length).to eq 3
        expect(actual[0]["name"]).to eq "blank"
      end
    end
  end

  context "check api for search project results" do
    it "Should return 'test2' project" do
      VCR.use_cassette("projects") do
        actual = GitlabApiServices.new(decrypt_access_token(users(:one).gitlab_token)).get_search_results(users(:one).gitlab_user_id, "test2")
        expect(actual[0]["name"]).to eq "test2"
      end
    end
  end

  context "check api for project details" do
    it "Should return project details" do
      VCR.use_cassette("project_details") do
        actual = GitlabApiServices.new(decrypt_access_token(users(:four).gitlab_token)).get_project_details(3892)
        expect(actual["name"]).to eq "blank"
      end
    end
  end

  context "check api for jobs of a project" do
    it "Should return jobs of project" do
      VCR.use_cassette("project_jobs_details") do
        actual = GitlabApiServices.new(decrypt_access_token(users(:one).gitlab_token)).get_project_jobs(3850)
        expect(actual[0]["commit"]["message"]).to eq "Update .gitlab-ci.yml"
      end
    end
  end




end
