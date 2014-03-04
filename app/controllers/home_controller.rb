class HomeController < ApplicationController
  def index
  	if params['user_name']
  		require 'open-uri'
  		require 'json'

  		proxy = "http://10.3.100.211:8080"

		base_url = "https://api.github.com"

		user_url = base_url+"/users/"+params['user_name']

		repo_url = base_url+"/users/"+params['user_name']+"/repos"
		
		if proxy
			@user = JSON.parse(open(user_url, :proxy => proxy).read)
		else
			@user = JSON.parse(open(user_url).read)
		end

		if @user['message'] == 'Not Found'

			@response[:status] = 'not found'
			respond_to do |format|
				format.json {render :json => @response.to_json.html_safe}
			end

		else
			if proxy
				@repos = JSON.parse(open(repo_url, :proxy => proxy).read)
			else
				@repos = JSON.parse(open(repo_url).read)
			end

			@forked = Array.new()
			@personal = Array.new()

			@languages= Hash.new()

			@f = 0
			@p = 0

			@repos.each do |repo|
				if repo['fork']
					@forked.push(repo)
					@f+=1
				else
					@personal.push(repo)

					if proxy
						@temp = JSON.parse(open(repo['languages_url'], :proxy => proxy).read)
					else
						@temp = JSON.parse(open(repo['languages_url']).read)
					end

					@temp.each do |key, val|
   						
						if @languages.include? key
   							@languages[key] = @languages[key] + val
   						else
   							@languages[key] = val
   						end

  					end

					@p+=1
				end
			end

			bytes = @languages.values

			total_bytes = bytes.inject(:+)

			@chart_data = Array.new()

			@languages.each do |key, val|
				temp = Hash.new()
				temp[:label] = key
				temp[:value] = val
				temp[:percent] = val*100/total_bytes
				@chart_data.push(temp)
			end

			@response = Hash.new()

			@user[:forked_repos_num] = @f
			@user[:personal_repos_num] = @p

			@response[:user] = @user
			@response[:forked_repos] = @forked
			@response[:personal_repos] = @personal
			@response[:languages] = @languages
			@response[:chart_data] = @chart_data
			@response[:status] = 'ok'

			respond_to do |format|
				format.json {render :json => @response.to_json.html_safe}
			end
		end
	else
		
  	end
  end

  def test
  end
end
