class Issue < ActiveRecord::Base




	has_paper_trail :on=>[:create, :destroy]

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

  
  # Search functionality for Index page
  def self.search(search)
    if search
      where('title LIKE ?', "%#{search}%")
    else
      scoped
    end
  end  

  # Relationship references
  def self.rel_references(rel_id)
    if rel_id
      Relationship.find(rel_id).references  
    else
      nil
    end
    
  end


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

  private
  def generate_slug   
    self.permalink = self.title.parameterize
  end  

end
