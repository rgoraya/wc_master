class Issue < ActiveRecord::Base

	has_paper_trail :on=>[:create, :destroy]

  # --------------------
  # Issues have an owner
  # --------------------
  belongs_to :user 
  # -------------------------------------------------------------
  # Relations that go forward - CAUSES, INHIBITORS AND SUPERSETS 
  # -------------------------------------------------------------
  has_many :relationships
  has_many :causes, :through => :relationships, :conditions => ['relationship_type IS NULL'], :order => 'relationships.updated_at DESC, relationships.references_count DESC'  
  has_many :inhibitors, :source=> :cause ,:through => :relationships, :conditions => ['relationship_type = "I"'], :order => 'relationships.updated_at DESC, relationships.references_count DESC'
  has_many :supersets, :source=> :cause, :through => :relationships, :conditions => ['relationship_type = "H"'], :order => 'relationships.updated_at DESC, relationships.references_count DESC'
  # -------------------------------------------------------------
  # Relations that go backwards - EFFECTS, INHIBITEDS AND SUBSETS 
  # -------------------------------------------------------------  
  has_many :inverse_relationships,:class_name=>"Relationship", :foreign_key=>"cause_id"
  has_many :effects,   :through=> :inverse_relationships, :source=>:issue, :conditions => ['relationship_type IS NULL'], :order => 'relationships.updated_at DESC, relationships.references_count DESC'
  has_many :inhibiteds,:through=> :inverse_relationships, :source=>:issue, :conditions => ['relationship_type = "I"'], :order => 'relationships.updated_at DESC, relationships.references_count DESC'  
  has_many :subsets,   :through=> :inverse_relationships, :source=>:issue, :conditions => ['relationship_type = "H"'], :order => 'relationships.updated_at DESC, relationships.references_count DESC'  
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
  
  # create friendly URL before saving
  before_validation :generate_slug 
  
  # Do the following on Destroy
  after_destroy :cleanup_relationships
  
  # destroy all associated relationships if the issue is destroyed
  def cleanup_relationships
    @involved_relationships = self.relationships
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

  private
  def generate_slug   
    self.permalink = self.title.parameterize
  end  

end
# == Schema Information
#
# Table name: issues
#
#  id                  :integer         not null, primary key
#  title               :string(255)
#  description         :string(255)
#  wiki_url            :string(255)
#  short_url           :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  permalink           :string(255)
#  user_id             :integer
#  relationships_count :integer
#

