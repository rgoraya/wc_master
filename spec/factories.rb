FactoryGirl.define do 
  factory :user do
    username              "Dummy"
    email                 "dummyboy@example.com"
    password              "foobar"
    password_confirmation "foobar"
  end
end       
