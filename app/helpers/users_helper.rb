module UsersHelper
  def gravatar_for(user, options = { :size   => 50, 
                                     :title  => "gravatar",
                                     :class  => "gravatar" })
    gravatar_image_tag(user.email.downcase, :alt      => user.username,
                                            :class    => options[:class],
                                            :title    => options[:title],
                                            :gravatar => options) 
  end 
end
