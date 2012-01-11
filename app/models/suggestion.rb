class Suggestion < ActiveRecord::Base

  has_paper_trail :on=>[:update], :only=>[:status] 

  belongs_to :issue

  def get_suggestions(url, issueid)

    if url.size > 10

      this_issue = Issue.find(issueid)
      @current_suggested = Hash.new
      @accepted = Hash.new 

      retrieve_suggested_relations_for_issue(this_issue)
      retrieve_accepted_relations_for_issue(this_issue)

      # Get the page contents into a buffer
      @buffer = Hpricot(open(url, "UserAgent" => "reader"+rand(10000).to_s).read)
 
      causes     = search_type_of_relation_in_text(issueid, 'C')
      effects    = search_type_of_relation_in_text(issueid, 'E')
      inhibitors = search_type_of_relation_in_text(issueid, 'I') 
      reduceds   = search_type_of_relation_in_text(issueid, 'R') 
      parents    = search_type_of_relation_in_text(issueid, 'P') 
      subsets    = search_type_of_relation_in_text(issueid, 'S') 

    end

    return causes.uniq, effects.uniq, inhibitors.uniq, reduceds.uniq, parents.uniq, subsets.uniq

  end

  def retrieve_suggested_relations_for_issue(this_issue)
    @current_suggested['causes']     = this_issue.suggestions.where(:causality => 'C').collect{|x| x.wiki_url}
    @current_suggested['effects']    = this_issue.suggestions.where(:causality => 'E').collect{|x| x.wiki_url}
    @current_suggested['inhibitors'] = this_issue.suggestions.where(:causality => 'I').collect{|x| x.wiki_url}
    @current_suggested['supersets']  = this_issue.suggestions.where(:causality => 'P').collect{|x| x.wiki_url}
    @current_suggested['inhibited']  = this_issue.suggestions.where(:causality => 'R').collect{|x| x.wiki_url}
    @current_suggested['subsets']    = this_issue.suggestions.where(:causality => 'S').collect{|x| x.wiki_url}
  end                    

  def retrieve_accepted_relations_for_issue(this_issue)
    @accepted['causes']     = this_issue.causes.collect{|x| x.wiki_url}
    @accepted['effects']    = this_issue.effects.collect{|x| x.wiki_url}
    @accepted['inhibitors'] = this_issue.inhibitors.collect{|x| x.wiki_url}
    @accepted['supersets']  = this_issue.supersets.collect{|x| x.wiki_url}
    @accepted['inhibited']  = this_issue.inhibited.collect{|x| x.wiki_url}
    @accepted['subsets']    = this_issue.subsets.collect{|x| x.wiki_url}
  end

  def search_type_of_relation_in_text(issueid, type_of_causality)

    puts type_of_causality.to_sym

    keywords_list = { 
      :C => ['cause', 'causes'],
      :I => ['prevent', 'inhibitors'],
      :P => ['type','supersets'],
      :E => ['effect', 'effects'],
      :R => ['reduce', 'inhibited'],
      :S => ['example', 'subsets'] 
    }[type_of_causality.to_sym]  
    
    puts keywords_list.first

    relation_ocurrences = Array.new

    @buffer.search('//p[text()*= "'+keywords_list.first+'"]/a').each { |relation|
      # the url of the suggestion
      relation_suggestion_url = 'http://en.wikipedia.org'+relation.attributes['href']
      # title of the suggestion
      relation_suggestion_title = URI.unescape(relation.attributes['href'].gsub("_" , " ").gsub(/[\w\W]*\/wiki\//, ""))

      puts keywords_list[1]
      # This suggestion does not exist already    
      if not @current_suggested[keywords_list[1]].include?(relation_suggestion_url)

        # Is this a suggestion that has been accepted as a cause already? 
        if @accepted[keywords_list[1]].include?(relation_suggestion_url)
          relation_ocurrences << {:title => relation_suggestion_title, :wiki_url => relation_suggestion_url, :causality => type_of_causality, :status => "A", :issue_id => issueid}

          # This suggestion has not been accepted
        else
          relation_ocurrences << {:title => relation_suggestion_title, :wiki_url => relation_suggestion_url, :causality => type_of_causality, :status => "N", :issue_id => issueid}
        end

      end

    } 
    return relation_ocurrences
  end   


end
