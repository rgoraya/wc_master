class GateController < ApplicationController
	require 'net/http'
	require 'open-uri'

	def get
		#response = Net::HTTP.get_response(URI.parse('http://ajax.googleapis.com/ajax/services/search/images?rsz=large&start=1&v=1.0&q=Deforestation'))
		#@data = ActiveSupport::JSON.decode(response.body)

		if params[:article]
			@issue = {}
			@issue[:title] = nil
			@issue[:description] = nil
			@issue[:wkpurl] = nil
			@issue[:wkcurl] = nil
			@issue[:image] = nil
			@issue[:causes] = []
			@issue[:effects] = []

			found = Issue.find(:all, :conditions=>['lower(wiki_url) = ?', params[:article].downcase]).first
			if found
				@issue[:title] = found.title
				@issue[:description] = found.description
				@issue[:wkpurl] = found.wiki_url
				@issue[:wkcurl] = "http://localhost:3000/issues/" + found.id.to_s
				@issue[:image] = found.short_url

				found.causes.each do |element|
					issue = {}
					issue[:title] = element.title
					issue[:description] = element.description
					issue[:wkpurl] = element.wiki_url
					issue[:wkcurl] = "http://localhost:3000/issues/" + element.id.to_s
					issue[:image] = element.short_url
					issue[:references] = []
					Relationship.find(:all, :conditions=>["issue_id=? AND cause_id=?", found.id, element.id]).first.references.each do |ref|
						issue[:references] << ref.reference_content
					end
					@issue[:causes] << issue
				end

				found.effects.each do |element|
					issue = {}
					issue[:title] = element.title
					issue[:description] = element.description
					issue[:wkpurl] = element.wiki_url
					issue[:wkcurl] = "http://localhost:3000/issues/" + element.id.to_s
					issue[:image] = element.short_url
					issue[:references] = []
					Relationship.find(:all, :conditions=>["issue_id=? AND cause_id=?", element.id, found.id]).first.references.each do |ref|
						issue[:references] << ref.reference_content
					end
					@issue[:effects] << issue
				end


				#tmp_arr = [@issue[:effects],@issue[:causes]]
				#[found.causes, found.effects].each do |collection|
				#	array = tmp_arr.pop
				#	collection.each do |element|
				#		issue = {}
				#		issue[:title] = element.title
				#		issue[:description] = element.description
				#		issue[:wkpurl] = element.wiki_url
				#		issue[:wkcurl] = "http://localhost:3000/issues/" + element.id.to_s
				#		issue[:image] = element.short_url
				#		issue[:references] = Relationship.find(:all, :conditions=>[]).first
				#		array << issue
				#	end
				#end
			end
		end
		
		@results = {}
		@results[:issue] = @issue		
	
		respond_to do |format|
			#format.html
			format.json {render :json => @results}
		end
	end

	def post
		#(params[:issue])[/http:\/\/en\.wikipedia\.org\/wiki\/[\w\d]+/i].eql?(params[:issue])
		status = 'Success'
		message = ''
		parameters = []
		causality = []

		if params[:issue]
			if (params[:issue])[/http:\/\/en\.wikipedia\.org\/wiki\/[\w\d\(\)\.]+/i].eql?(params[:issue])
				causality << params[:issue]
				if !Issue.find(:all, :conditions=>['lower(wiki_url) = ?', params[:issue].downcase]).first
					parameters << params[:issue]
				end
				if params[:cause]
					if (params[:cause])[/http:\/\/en\.wikipedia\.org\/wiki\/[\w\d\(\)\.]+/i].eql?(params[:cause])
						causality << params[:cause]
						if !Issue.find(:all, :conditions=>['lower(wiki_url) = ?', params[:cause].downcase]).first
							parameters << params[:cause]
						end
						if params[:issue].downcase.eql?(params[:cause].downcase)
							parameters.clear
							causality.clear
							status = 'Failure'
							message = 'Duplicate URLs'
						end
					else
						parameters.clear
						status = 'Failure'
						message = "Invalid url: \'#{params[:cause]}\'. Linking failed! "
					end
				end
			else
				parameters.clear
				status = 'Failure'
				message = "Invalid url: \'#{params[:issue]}\' "
			end
		else
			status = 'Failure'
			message = 'Invalid parameters'
		end


		parameters.each do |url|
			begin
				document = Hpricot(open(url))
				title = url.gsub(/http:\/\/en\.wikipedia\.org\/wiki\//i,'').gsub(/_/,' ').capitalize
				description = (document.search("p"))[0].inner_text.gsub(/\[\d*\]/,"")
				wiki_url = url
				short_url = ''
				user_id = ''
				if document.search("img[@class='thumbimage']")[0] && document.search("img[@class='thumbimage']")[0]["src"]
					short_url = document.search("img[@class='thumbimage']")[0]["src"]
				else
					response = Net::HTTP.get_response(URI.parse('http://ajax.googleapis.com/ajax/services/search/images?rsz=large&start=1&v=1.0&q=' + URI.escape(title)))
					data = ActiveSupport::JSON.decode(response.body)
					short_url = data["responseData"]["results"][0]["tbUrl"]
				end
		
				issue = Issue.new
				issue.title = title
				issue.description = description
				issue.wiki_url = wiki_url
				issue.short_url = short_url
				issue.save
			rescue
				status = 'Failure'
				message += "Creating issue: \'#{wiki_url}\' failed! "
			end
		end

		if causality.length == 2
			begin
				if !Relationship.find(:all, :conditions=>['issue_id = ? AND cause_id = ?', Issue.find(:all,:conditions=>['lower(wiki_url) = ?', causality[0].downcase]).first.id,Issue.find(:all,:conditions=>['lower(wiki_url) = ?', causality[1].downcase]).first.id]).first
					relationship = Relationship.new			
					relationship.issue_id = Issue.find(:all,:conditions=>['lower(wiki_url) = ?', causality[0].downcase]).first.id
					relationship.cause_id = Issue.find(:all,:conditions=>['lower(wiki_url) = ?', causality[1].downcase]).first.id
					relationship.save
				else
					status = 'Success'
					message += "Causality is already created!  "
				end
			rescue
				status = 'Failure'
				message += "Linking failed! "
			end 
		end
		
		@response = {}	
		@response[:status] = status
		@response[:message] = message		
	
		respond_to do |format|
			#format.html
			format.json {render :json => @response}
		end
		
	end

end
