class Issue < ActiveRecord::Base

	has_paper_trail

  # --------------------
  # Issues have an owner
  # --------------------
  belongs_to :user 
  # -------------------------------------------------------------
  # Relations that go forward - CAUSES, INHIBITORS AND SUPERSETS 
  # -------------------------------------------------------------
  has_many :relationships, :dependent => :destroy
  has_many :causes, :through => :relationships, :conditions => ['relationship_type IS NULL'], :order => 'relationships.created_at DESC, relationships.references_count DESC'  
  has_many :inhibitors, :source=> :cause ,:through => :relationships, :conditions => ['relationship_type = "I"'], :order => 'relationships.created_at DESC, relationships.references_count DESC'
  has_many :supersets, :source=> :cause, :through => :relationships, :conditions => ['relationship_type = "H"'], :order => 'relationships.created_at DESC, relationships.references_count DESC'
  # -------------------------------------------------------------
  # Relations that go backwards - EFFECTS, INHIBITEDS AND SUBSETS 
  # -------------------------------------------------------------  
  has_many :inverse_relationships,:class_name=>"Relationship", :foreign_key=>"cause_id", :dependent => :destroy
  has_many :effects,   :through=> :inverse_relationships, :source=>:issue, :conditions => ['relationship_type IS NULL'], :order => 'relationships.created_at DESC, relationships.references_count DESC'
  has_many :inhibiteds,:through=> :inverse_relationships, :source=>:issue, :conditions => ['relationship_type = "I"'], :order => 'relationships.created_at DESC, relationships.references_count DESC'  
  has_many :subsets,   :through=> :inverse_relationships, :source=>:issue, :conditions => ['relationship_type = "H"'], :order => 'relationships.created_at DESC, relationships.references_count DESC'  
  # ------------
  # Suggestions
  # ------------
  has_many :suggestions

  # ------------
  # VALIDATIONS
  # ------------
  validates_uniqueness_of :wiki_url, :case_sensitive => false, :message=>" (wikipedia URL) provided was already used to create an existing Issue."

  
  # The wiki_url has to be unique else do not create
  validates_uniqueness_of :wiki_url, :case_sensitive => false, :message=>" duplicated."

  validates :title, :presence => {:message => ' cannot be blank, Issue not saved!'}
  validates :wiki_url, :presence => {:message => ' cannot be blank, Issue not saved!'}
  validates :short_url, :presence => {:message => ' cannot be blank, Issue not saved!'}
  validates :description, :presence => {:message => ' cannot be blank, Issue not saved!'}
  
  
  # Do the following on Destroy
  after_destroy :cleanup_relationships
  
  # create friendly URL before saving
  before_validation :generate_slug  
  
  # destroy all associated relationships if the issue is destroyed
  def cleanup_relationships
    @involved_relationships = Relationship.where(:cause_id => self.id)
    @iterations = @involved_relationships.length
    @iterations.times do |i|
      @involved_relationships[i].destroy
    end
  end
  
  
  # routes based on friendly URLs
  def to_param
    "#{id}-#{permalink}"
  end  

  
  # search functionality for Index page
  def self.search(search)
    if search
      where('title LIKE ?', "%#{search}%")
    else
      scoped
    end
  end  

  # search functionality for Index page
  def self.search_results(query)
    if query
      where('title LIKE ?', "%#{query}%").first
    else
      scoped
    end
  end 

  def self.rel_references(rel_id)
    if rel_id
      Relationship.find(rel_id).references  
    else
      nil
    end
    
  end

  def self.select_relationship_type(rel_type)
    
    @issue = Issue.find_by_id(:id)
    case rel_type


    when "causes", ""
      # get the causes
      @issue_causes = @issue.causes.paginate(:per_page => 6, :page => params[:relationship_page])
      # insert relationship_id
      #@issue_causes.each do |cause|
      #  @rel_id = @issue.relationships.where(:cause_id=>cause.id, :relationship_type=>nil).select('id').first.id
      #  cause.attributes << {:rel_id => @rel_id}
      #  
      #end
      # return this
      #return @issue_causes
    
    when "effects"
      # get the causes
      @issue_effects = Issue.effects.paginate(:per_page => 6, :page => params[:relationship_page])
      # insert relationship_id
      @issue_effects.each do |effect|
        @rel_id = Relationship.where(:issue_id=>effect.id, :cause_id=>@issue.id, :relationship_type=>nil).select('id').first.id
        effect << {:rel_id => @rel_id} 
      end
      # return this
      return @issue_effects
    
    when "inhibitors"
      # get the causes
      @issue_inhibitors = Issue.inhibitors.paginate(:per_page => 6, :page => params[:relationship_page])
      # insert relationship_id
      @issue_inhibitors.each do |inhibitor|
        @rel_id = @issue.relationships.where(:cause_id=>inhibitor.id, :relationship_type=>nil).select('id').first.id
        inhibitor << {:rel_id => @rel_id} 
      end
      # return this
      return @issue_inhibitors
          
    when "inhibiteds"
      # get the inhibiteds
      @issue_inhibiteds = Issue.inhibiteds.paginate(:per_page => 6, :page => params[:relationship_page])
      # insert relationship_id
      @issue_inhibiteds.each do |inhibited|
        @rel_id = Relationship.where(:issue_id=>inhibited.id, :cause_id=>@issue.id, :relationship_type=>'I').select('id').first.id
        inhibited << {:rel_id => @rel_id} 
      end
      # return this
      return @issue_inhibiteds
    
    when "supersets"
      # get the causes
      @issue_supersets = Issue.supersets.paginate(:per_page => 6, :page => params[:relationship_page])
      # insert relationship_id
      @issue_supersets.each do |superset|
        @rel_id = @issue.relationships.where(:cause_id=>superset.id, :relationship_type=>'H').select('id').first.id
        superset << {:rel_id => @rel_id} 
      end
      # return this
      return @issue_supersets
    
    when "subsets"
      # get the subsets
      @issue_subsets = Issue.subsets.paginate(:per_page => 6, :page => params[:relationship_page])
      # insert relationship_id
      @issue_subsets.each do |subset|
        @rel_id = Relationship.where(:issue_id=>subset.id, :cause_id=>@issue.id, :relationship_type=>'H').select('id').first.id
        subset << {:rel_id => @rel_id} 
      end
      # return this
      return @issue_subsets
      
   end
    
  end
  
  
  # SQL for getting Effects on the Issue page
  #def effects
  #  Issue.find_by_sql "
  #    select id, title, permalink, description, short_url, wiki_url
  #    from issues
  #    where id in (
  #      select issue_id
  #      from relationships
  #      where cause_id = #{id} AND relationship_type IS NULL)"  
  #end

  # SQL for getting Effects on the Issue page
  #def inhibiteds
  #  Issue.find_by_sql "
  #    select id, title, permalink, description, short_url, wiki_url
  #    from issues
  #    where id in (
  #      select issue_id
  #      from relationships
  #      where cause_id = #{id} AND relationship_type = 'I')"
  #end

  # SQL for getting Effects on the Issue page
  #def subsets
  #  Issue.find_by_sql "
  #    select id, title, permalink, description, short_url, wiki_url
  #    from issues
  #    where id in (
  #      select issue_id
  #      from relationships
  #      where cause_id = #{id} AND relationship_type = 'H')"
  #end

  # SQL for getting Effects on the Issue page

  #Method to get the link for Wikipedia from Google search results
  def get_wiki_url(query)
      search_keywords = query.strip.gsub(/\s+/,'+')
      url = "http://www.google.com/search?q=#{search_keywords}+site%3Aen.wikipedia.org&safe=active"
      begin
        doc = Hpricot(open(url, "UserAgent" => "reader"+rand(10000).to_s).read)
        result = doc.search("//div[@id='ires']").search("//li[@class='g']").first.search("//a").first
      rescue
        return ''
      end
      if result
        return result.attributes["href"]
      else
        return ''
      end
  end

require  'hpricot'
require 'open-uri'
require 'json'
require 'cgi'
require 'wikipedia'
require 'uri'

  #def get_wiki_description(query)
  #    
  #    # get the respective WIKIPEDIA link from Google 
  #    url = get_wiki_url(query).to_s
      
  #    final_imgcontent = ""
  #    imgcontainer = ""
  #    imgcontent = ""
  #    imgcaption = ""
  #    toc = ""
      
  #    if url.size > 10
        
  #      begin
  #        # Get the page contents into a buffer
  #        buffer = Hpricot(open(url, "UserAgent" => "reader"+rand(10000).to_s).read)
          
  #        # Capture first paragraph of the text
  #        content = buffer.search("//div[@id='content']").search("//div[@id='bodyContent']").search("//p").first
    
  #        # Retrieve plain text
  #        text = content.to_plain_text
  #        text = text.gsub(/< \/?[^>]*>/, '').gsub(/&#\d+;/,'').gsub(/\([^\)]+\)/,'').gsub(/\[[^\]]+\]/,'').gsub(/ +/,' ').gsub(/\[\d\]/,'')
          
  #        # Limit the length of the text to be displayed
  #        if text.size > 450
  #          text = text[1,450] << '...'  
  #        end
  #      
  #      rescue
  #        text = 'No description could be retrieved from Wikipedia'
  #      end
        
  #      # Retrieve the URL for first attached image file on WIKIPEDIA 
  #      begin
  #        imgcontainer = buffer.search("//div[@id='content']").search("//div[@id='bodyContent']").search("//div[@class='thumb tright']").first.search("//div[@class='thumbinner']")
  #        
  #        imgcontent = imgcontainer.search("//a").first.search("//img").first
  #        imgcaption = imgcontainer.search("//div[@class='thumbcaption']").first
  #        
  #        final_imgcontent = imgcontent.attributes["src"]
  #        final_imgcaption = imgcaption.to_plain_text.gsub(/< \/?[^>]*>/, '').gsub(/&#\d+;/,'').gsub(/\([^\)]+\)/,'').gsub(/\[[^\]]+\]/,'').gsub(/ +/,' ')
  #        
  #      rescue
  #        final_imgcontent = get_google_img(query)
  #        final_imgcaption = 'Image Courtesy: Google'
  #      end
  #      
  #      begin
  #        issue_title = buffer.search("h1[@id='firstHeading']").first
  #        issue_title = issue_title.to_plain_text
  #        
  #      rescue
  #        issue_title = query
  #      end
        
  #    end
  #    return url, final_imgcontent, text, final_imgcaption, issue_title
  #end

  # Get the Google image result if Wikipedia does not have an image attached
  #def get_google_img(query)
  #    img_search_keywords = query.strip.gsub(/\s+/,'+')
      
  #    if img_search_keywords != ''
  #      url = "http://ajax.googleapis.com/ajax/services/search/images?rsz=large&start=1&v=1.0&q=#{img_search_keywords}"
  #      
  #      json_results = open(url) {|f| f.read };
  #      results = JSON.parse(json_results)
  #      image_array = results['responseData']['results']
  #      image = image_array[0] if image_array
  #      image = image['tbUrl']
  #      
  #      if image
  #        return image
  #      else
  #        return 'no image found'
  #      end
  #    end
  #end

  #def get_links(query)
  #  page = Wikipedia.find(query)
  #  return 
  #end

  #def get_causes(url)

  #    results = []
  #    effects = []
  #    if url.size > 10
        
  #      begin
  #        # Get the page contents into a buffer
  #        buffer = Hpricot(open(url, "UserAgent" => "reader"+rand(10000).to_s).read)
          
  #              buffer.search('//p[text()*= "cause"]/a').each { |result|
  #               results << {:name => URI.unescape(result.attributes['href'].gsub("_" , " ").gsub("\/wiki\/", "")), :url => 'http://en.wikipedia.org'+result.attributes['href']}
  #              }

  #              buffer.search('//p[text()*= "effect"]/a').each { |effect|
  #               effects << {:name => URI.unescape(effect.attributes['href'].gsub("_" , " ").gsub("\/wiki\/", "")), :url => 'http://en.wikipedia.org'+effect.attributes['href']}
  #              }              
        
  #      rescue
                    
  #      end
        
  #    end
  #   return results.uniq, effects.uniq
      
  #end

  #def get_related_resources(wikiped_url)
  #key = wikiped_url.gsub(/(http:\/\/)*(www\.)*en\.wikipedia\.org\/wiki\//,"")
  #query ="PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
  #SELECT DISTINCT * 
  #WHERE
  #{
  #<http://dbpedia.org/resource/#{key}> <http://purl.org/dc/terms/subject> ?topic.
  #MINUS{
  #?topic skos:broader <http://dbpedia.org/resource/Category:Terminology>
  #}
  #?relatedResources <http://purl.org/dc/terms/subject> ?topic.
  #MINUS{ 
  #?relatedResources rdf:type <http://dbpedia.org/ontology/Person>.
  #relatedResources rdf:type <http://dbpedia.org/ontology/date>.
  #}}"
  #  query = CGI.escape(query)
  #  terms = []
  #  begin
  #    doc = Hpricot(open("http://dbpedia.org/sparql?default-graph-uri=#{CGI.escape('http://dbpedia.org')}&query=#{query}").read)
  #    doc.search("//binding[@name='relatedResources']//uri").each {|t|
  #      terms << "http://en.wikipedia.org/wiki/#{t.inner_text.gsub(/http:\/\/dbpedia\.org\/resource\//,"")}"  
  #    }
  #  rescue
  #    return nil
  # end
  #  return terms
  #end

  private
  def generate_slug   
    self.permalink = self.title.parameterize
  end  

end
