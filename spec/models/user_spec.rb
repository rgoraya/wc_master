require 'spec_helper'

describe User do
  before(:each) do
    @attr = {:name => "Example user", 
             :email => "user@example.com", 
             :password => "password",
             :password_confirmation => "password"}  
  end
end
