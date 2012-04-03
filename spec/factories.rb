FactoryGirl.define do 
  factory :user do
    username              "Dummy"
    email                 "dummyboy@example.com"
    password              "foobar"
    password_confirmation "foobar"
  end

  factory :issue do 
    title                 "example"
    wiki_url              "http://en.wikipedia.org/wiki/Long_Island"
    short_url             "http://en.wikipedia..."
    description           "exampledescription"
  end

  factory :comment do
    content               "Comment number one"
    relationship_id       1
  end
  
  sequence :email do |n|
    "person#{n}@example.com"
  end
end       
