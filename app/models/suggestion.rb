class Suggestion < ActiveRecord::Base

has_paper_trail :on=>[:update], :only=>[:status] 


belongs_to :issue

  def get_suggestions(url, issueid)

      if url.size > 10

      causes = []
      effects = []
      inhibitors = []
      reduceds = []
      parents = []
      subsets = []
      
      
      this_issue = Issue.find(issueid)

      current_suggested_causes     = this_issue.suggestions.where(:causality => 'C').collect{|x| x.wiki_url}
      current_suggested_effects    = this_issue.suggestions.where(:causality => 'E').collect{|x| x.wiki_url}
      current_suggested_inhibitors = this_issue.suggestions.where(:causality => 'I').collect{|x| x.wiki_url}
      current_suggested_supersets  = this_issue.suggestions.where(:causality => 'P').collect{|x| x.wiki_url}      
      current_suggested_inhibited  = this_issue.suggestions.where(:causality => 'R').collect{|x| x.wiki_url}      
      current_suggested_subsets    = this_issue.suggestions.where(:causality => 'S').collect{|x| x.wiki_url}      
      
      accepted_causes = this_issue.causes.collect{|x| x.wiki_url}
      accepted_effects = this_issue.effects.collect{|x| x.wiki_url}        
      accepted_inhibitors = this_issue.inhibitors.collect{|x| x.wiki_url}
      accepted_supersets = this_issue.supersets.collect{|x| x.wiki_url}
      accepted_inhibited = this_issue.inhibited.collect{|x| x.wiki_url}
      accepted_subsets = this_issue.subsets.collect{|x| x.wiki_url}      
        
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

          buffer.search('//p[text()*= "prevent"]/a').each { |inhibitor|
            # the url of the suggestion
            inhibitor_suggestion_url = 'http://en.wikipedia.org'+inhibitor.attributes['href']
            # title of the suggestion
            inhibitor_suggestion_title = URI.unescape(inhibitor.attributes['href'].gsub("_" , " ").gsub("\/wiki\/", ""))

            # This suggestion does not exist already    
            if not current_suggested_inhibitors.include?(inhibitor_suggestion_url)

              # Is this a suggestion that has been accepted as a cause already? 
              if accepted_inhibitors.include?(inhibitor_suggestion_url)
                inhibitors << {:title => inhibitor_suggestion_title, :wiki_url => inhibitor_suggestion_url, :causality=>"I", :status=>"A", :issue_id=>issueid}

              # This suggestion has not been accepted
              else
                inhibitors << {:title => inhibitor_suggestion_title, :wiki_url => inhibitor_suggestion_url, :causality=>"I", :status=>"N", :issue_id=>issueid}
              end

            end
          
          }

          buffer.search('//p[text()*= "reduce"]/a').each { |reduced|
            # the url of the suggestion
            reduced_suggestion_url = 'http://en.wikipedia.org'+reduced.attributes['href']
            # title of the suggestion
            reduced_suggestion_title = URI.unescape(reduced.attributes['href'].gsub("_" , " ").gsub("\/wiki\/", ""))
                
            # This suggestion does not exist already    
            if not current_suggested_inhibited.include?(reduced_suggestion_url)
   
              # Is this a suggestion that has been accepted as a cause already? 
              if accepted_inhibited.include?(reduced_suggestion_url)
                reduceds << {:title => reduced_suggestion_title, :wiki_url => reduced_suggestion_url, :causality=>"R", :status=>"A", :issue_id=>issueid}
              
              # This suggestion has not been accepted
              else
                reduceds << {:title => reduced_suggestion_title, :wiki_url => reduced_suggestion_url, :causality=>"R", :status=>"N", :issue_id=>issueid}
              end
          
            end
          
          }         

          buffer.search('//p[text()*= "type"]/a').each { |parent|
            # the url of the suggestion
            parent_suggestion_url = 'http://en.wikipedia.org'+parent.attributes['href']
            # title of the suggestion
            parent_suggestion_title = URI.unescape(parent.attributes['href'].gsub("_" , " ").gsub("\/wiki\/", ""))
                
            # This suggestion does not exist already    
            if not current_suggested_supersets.include?(parent_suggestion_url)
   
              # Is this a suggestion that has been accepted as a cause already? 
              if accepted_supersets.include?(parent_suggestion_url)
                parents << {:title => parent_suggestion_title, :wiki_url => parent_suggestion_url, :causality=>"P", :status=>"A", :issue_id=>issueid}
              
              # This suggestion has not been accepted
              else
                parents << {:title => parent_suggestion_title, :wiki_url => parent_suggestion_url, :causality=>"P", :status=>"N", :issue_id=>issueid}
              end
          
            end
          
          }         
        
          buffer.search('//p[text()*= "example"]/a').each { |subset|
            # the url of the suggestion
            subset_suggestion_url = 'http://en.wikipedia.org'+subset.attributes['href']
            # title of the suggestion
            subset_suggestion_title = URI.unescape(subset.attributes['href'].gsub("_" , " ").gsub("\/wiki\/", ""))
                
            # This suggestion does not exist already    
            if not current_suggested_subsets.include?(subset_suggestion_url)
   
              # Is this a suggestion that has been accepted as a cause already? 
              if accepted_subsets.include?(subset_suggestion_url)
                subsets << {:title => subset_suggestion_title, :wiki_url => subset_suggestion_url, :causality=>"S", :status=>"A", :issue_id=>issueid}
              
              # This suggestion has not been accepted
              else
                subsets << {:title => subset_suggestion_title, :wiki_url => subset_suggestion_url, :causality=>"S", :status=>"N", :issue_id=>issueid}
              end
          
            end
          
          } 
        
        rescue
            #causes << {:title => 'A', :wiki_url => url, :causality=>'C', :status=>'N', :issue_id=>issueid}
            #effects << {:title => 'A', :wiki_url => url, :causality=>'E', :status=>'N', :issue_id=>issueid}
        end
        
      end
      
      return causes.uniq, effects.uniq, inhibitors.uniq, reduceds.uniq, parents.uniq, subsets.uniq
      
  end

end
