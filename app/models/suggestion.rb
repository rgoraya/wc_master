class Suggestion < ActiveRecord::Base

  has_paper_trail :on=>[:update], :only=>[:status] 

  belongs_to :issue

  KEYWORDS = {  #should be filled with several keywords related to each of the types
    :C => ['cause', 'proposed'],
    :I => ['prevent', 'reduced by'],
    :P => ['type'],
    :E => ['effect','maximizes'],
    :R => ['reduce','minimizes'],
    :S => ['example','forms of'] 
  }

  CAUSALITY_TYPES = {
    :C => 'causes',                                         
    :I => 'inhibitors',
    :P => 'supersets',
    :E => 'effects',
    :R => 'inhibited',
    :S => 'subsets'  
  }

  def get_suggestions(url, issueid)

    if url.size > 10

      this_issue         = Issue.find(issueid)
      @current_suggested = {}
      @accepted          = {}

      retrieve_suggested_relations_for_issue(this_issue)
      retrieve_accepted_relations_for_issue(this_issue)

      # Get the page contents into a buffer
      @buffer = Hpricot(open(url, "UserAgent" => "reader"+rand(10000).to_s).read)

      causes     = search_type_of_relation_in_text(issueid, 'C')
      effects    = search_type_of_relation_in_text(issueid, 'E')
      inhibitors = search_type_of_relation_in_text(issueid, 'I') 
      reduceds   = search_type_of_relation_in_text(issueid, 'R') 
      parents    = search_type_of_relation_in_text(issueid, 'P') + search_superset_in_table(issueid)
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


  def search_type_of_relation_in_text(issue_id, type_of_causality)
    KEYWORDS[type_of_causality.to_sym].collect do |keyword|
      search_word(keyword, type_of_causality, issue_id)
    end
  end

  def search_word(keyword, relation_type, issue_id)
    relation_occurrences = [ ]
                                                                        
    suggestions_counter = 0

    @buffer.search(%Q{//p[text()*= "#{keyword}'"]/a}).each do |relation| unless @suggestions_counter == 6 
    relation_suggestion_url            = "http://en.wikipedia.org#{relation.attributes['href']}"
    relation_suggestion_title          = URI.unescape(relation.attributes['href'].gsub("_" , " ").gsub(/[\w\W]*\/wiki\//, ""))
    occurrence                         = create_relation_occurrence(relation_suggestion_title, relation_suggestion_url, relation_type, issue_id)
    @suggestions_counter += 1

    relation_occurrences << occurrence
    end end

    @suggestions_counter = 0

    relation_occurrences
  end  

  def create_relation_occurrence(relation_suggestion_title, relation_suggestion_url, relation_type, issue_id)
    causality_type = CAUSALITY_TYPES[relation_type.to_sym]

    if (!@current_suggested[causality_type].include?(relation_suggestion_url))
      occurrence = {
        :title     => relation_suggestion_title,
        :wiki_url  => relation_suggestion_url,
        :causality => relation_type,
        :issue_id  => issue_id
      }
      
      @accepted[causality_type].include?(relation_suggestion_url) ? occurrence[:status] = 'A' : occurrence[:status] = 'N'
    end
   
    occurrence
  end                               

  def search_superset_in_table(issue_id)
    relation_occurrences = [ ]

    @buffer.search('table.infobox').search('th').search('b').search('a') do |link|
      relation_suggestion_url   = "http://en.wikipedia.org#{link.attributes['href']}"
      relation_suggestion_title = link.attributes['title']
      occurrence                = create_relation_occurrence(relation_suggestion_title, relation_suggestion_url, 'P', issue_id)

      relation_occurrences << occurrence
    end

    relation_occurrences
  end  

end
