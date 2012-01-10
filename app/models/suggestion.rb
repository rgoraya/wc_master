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

      current_suggested = retrieve_suggested_relations_for_issue(this_issue)
      accepted = retrieve_accepted_relations_for_issue(this_issue)

      begin
        # Get the page contents into a buffer
        buffer = Hpricot(open(url, "UserAgent" => "reader"+rand(10000).to_s).read)

        buffer.search('//p[text()*= "cause"]/a').each { |cause|
          # the url of the suggestion
          suggestion_url = 'http://en.wikipedia.org'+cause.attributes['href']
          # title of the suggestion
          suggestion_title = URI.unescape(cause.attributes['href'].gsub("_" , " ").gsub(/[\w\W]*\/wiki\//, ""))

          # This suggestion does not exist already    
          if not current_suggested['causes'].include?(suggestion_url)

            # Is this a suggestion that has been accepted as a cause already? 
            if accepted['causes'].include?(suggestion_url)
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
          effect_suggestion_title = URI.unescape(effect.attributes['href'].gsub("_" , " ").gsub(/[\w\W]*\/wiki\//, ""))

          # This suggestion does not exist already    
          if not current_suggested['effects'].include?(effect_suggestion_url)

            # Is this a suggestion that has been accepted as an effect already? 
            if accepted['effects'].include?(effect_suggestion_url) 
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
          inhibitor_suggestion_title = URI.unescape(inhibitor.attributes['href'].gsub("_" , " ").gsub(/[\w\W]*\/wiki\//, ""))

          # This suggestion does not exist already    
          if not current_suggested['inhibitors'].include?(inhibitor_suggestion_url)

            # Is this a suggestion that has been accepted as a cause already? 
            if accepted['inhibitors'].include?(inhibitor_suggestion_url)
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
          reduced_suggestion_title = URI.unescape(reduced.attributes['href'].gsub("_" , " ").gsub(/[\w\W]*\/wiki\//, ""))

          # This suggestion does not exist already    
          if not current_suggested['inhibited'].include?(reduced_suggestion_url)

            # Is this a suggestion that has been accepted as a cause already? 
            if accepted['inhibited'].include?(reduced_suggestion_url)
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
          parent_suggestion_title = URI.unescape(parent.attributes['href'].gsub("_" , " ").gsub(/[\w\W]*\/wiki\//, ""))

          # This suggestion does not exist already    
          if not current_suggested['supersets'].include?(parent_suggestion_url)

            # Is this a suggestion that has been accepted as a cause already? 
            if accepted['supersets'].include?(parent_suggestion_url)
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
          subset_suggestion_title = URI.unescape(subset.attributes['href'].gsub("_" , " ").gsub(/[\w\W]*\/wiki\//, ""))

          # This suggestion does not exist already    
          if not current_suggested['subsets'].include?(subset_suggestion_url)

            # Is this a suggestion that has been accepted as a cause already? 
            if accepted['subsets'].include?(subset_suggestion_url)
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

  def retrieve_suggested_relations_for_issue(this_issue)
    current_suggested               = Hash.new
    current_suggested['causes']     = this_issue.suggestions.where(:causality => 'C').collect{|x| x.wiki_url}
    current_suggested['effects']    = this_issue.suggestions.where(:causality => 'E').collect{|x| x.wiki_url}
    current_suggested['inhibitors'] = this_issue.suggestions.where(:causality => 'I').collect{|x| x.wiki_url}
    current_suggested['supersets']  = this_issue.suggestions.where(:causality => 'P').collect{|x| x.wiki_url}
    current_suggested['inhibited']  = this_issue.suggestions.where(:causality => 'R').collect{|x| x.wiki_url}
    current_suggested['subsets']    = this_issue.suggestions.where(:causality => 'S').collect{|x| x.wiki_url}
    return current_suggested
  end                    

  def retrieve_accepted_relations_for_issue(this_issue)
    accepted               = Hash.new
    accepted['causes']     = this_issue.causes.collect{|x| x.wiki_url}
    accepted['effects']    = this_issue.effects.collect{|x| x.wiki_url}
    accepted['inhibitors'] = this_issue.inhibitors.collect{|x| x.wiki_url}
    accepted['supersets']  = this_issue.supersets.collect{|x| x.wiki_url}
    accepted['inhibited']  = this_issue.inhibited.collect{|x| x.wiki_url}
    accepted['subsets']    = this_issue.subsets.collect{|x| x.wiki_url}
    return accepted    
  end


end
