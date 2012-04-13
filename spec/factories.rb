FactoryGirl.define do 
  factory :relationship do
    sequence(:issue_id)  { |n| n }
    sequence(:cause_id)  { |n| n+1 }
    relationship_type     "C"
    user
  end   

  factory :user do
    sequence(:username)  { |n| "Person #{n}" }
    sequence(:email)     { |n| "person_#{n}@example.com"}   
    password              "foobar"
    password_confirmation "foobar"
  end

  factory :issue do 
    title                 "Electricity"
    wiki_url              "http://en.wikipedia.org/wiki/Electricity"
    short_url             "http://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Lightning3.jpg/220px-Lightning3.jpg"
    description           "Electricity is the science, engineering, technology and physical phenomena associated with the presence and flow of electric charges. Electricity gives a wide variety of well-known electrical effects, such as lightning, static electricity, electromagnetic induction and the flow of electrical current in an electrical wire. In addition, electricity permits the creation and reception of electromagnetic radiation such as radio waves."
  end

  factory :comment do
    content               "Comment number one"
    relationship_id       1
  end
  
  sequence :email do |n|
    "person#{n}@example.com"
  end
end       
