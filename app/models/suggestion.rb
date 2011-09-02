class Suggestion < ActiveRecord::Base

belongs_to :issue

  def get_suggestions(url, issueid)

      if url.size > 10

      causes = []
      effects = []
      
      this_issue = Issue.find(issueid)

      current_suggested_causes  = this_issue.suggestions.where(:causality => 'C').collect{|x| x.wiki_url}
      current_suggested_effects = this_issue.suggestions.where(:causality => 'E').collect{|x| x.wiki_url}
      
      accepted_causes = this_issue.causes.collect{|x| x.wiki_url}
      accepted_effects = this_issue.effects.collect{|x| x.wiki_url}        
        
        
        begin
          # Get the page contents into a buffer
          buffer = Hpricot(open(url, "UserAgent" => "reader"+rand(10000).to_s).read)
          
          buffer.search('//p[text()*= "cause"]/a').each { |cause|
            # the url of the suggestion
            suggestion_url = 'http://en.wikipedia.org'+cause.attributes['href']
            # title of the suggestion
            suggestion_title = URI.unescape(cause.attributes['href'].gsub("_" , " ").gsub("\/wiki\/", ""))
                
            # This suggestion does not exist already    
            if not current_suggested_causes.include?(suggestion_url)
   
              # Is this a suggestion that has been accepted as a cause already? 
              if accepted_causes.include?(suggestion_url)
                causes << {:title => suggestion_title, :wiki_url => suggestion_url, :causality=>"C", :status=>"A", :issue_id=>issueid}
              
              # This suggestion has not been accepted
              else
                causes << {:title => suggestion_title, :wiki_url => suggestion_url, :causality=>"C", :status=>"N", :issue_id=>issueid}
              end
          
            end
          
          }

          buffer.search('//p[text()*= "effect"]/a').each { |effect|
            # the url of the suggestion
            effect_suggestion_url = 'http://en.wikipedia.org'+effect.attributes['href']
            # title of suggestion
            effect_suggestion_title = URI.unescape(effect.attributes['href'].gsub("_" , " ").gsub("\/wiki\/", ""))

            # This suggestion does not exist already    
            if not current_suggested_effects.include?(effect_suggestion_url)
              
              # Is this a suggestion that has been accepted as an effect already? 
              if accepted_effects.include?(effect_suggestion_url) 
                effects << {:title =>effect_suggestion_title, :wiki_url=>effect_suggestion_url , :causality=>"E", :status=>"A", :issue_id=>issueid}
              
              # This suggestion has not been accepted
              else
                effects << {:title =>effect_suggestion_title, :wiki_url=>effect_suggestion_url , :causality=>"E", :status=>"N", :issue_id=>issueid}
              end
            end
         
          }              
        
        rescue
            causes << {:title => 'A', :wiki_url => url, :causality=>'C', :status=>'N', :issue_id=>issueid}
            effects << {:title => 'A', :wiki_url => url, :causality=>'E', :status=>'N', :issue_id=>issueid}
        end
        
      end
      
      return causes.uniq, effects.uniq
      
  end

end
