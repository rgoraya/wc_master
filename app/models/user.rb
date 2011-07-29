class User < ActiveRecord::Base
  
  # following code makes the user model to work as AUTHLOGIC authentication class
  acts_as_authentic

  has_many :issues

  # search functionality
  def self.search(search)
    if search
      where('issue.title LIKE ?', "%#{search}%")
    else
      scoped
    end
  end

end
