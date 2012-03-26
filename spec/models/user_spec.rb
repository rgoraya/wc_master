require 'spec_helper'

describe User do
  before(:each) do
    @attr = {:username => "Example user", 
             :email => "user@example.com", 
             :password => "password",
             :password_confirmation => "password"}  
  end

  it "should create an instance given a valid attribute" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:username => ""))
    no_name_user.should_not be_valid
  end
 
  it "should require an email address" do
    no_name_user = User.new(@attr.merge(:email => ""))
    no_name_user.should_not be_valid
  end                               

  it "should reject names that are long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:username => long_name))
    long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp] 
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end     
  end

  it "should reject invalid email addresses" do 
    addresses = %w[user@foo,com THE_USER_atfoo.org first.last@foo.] 
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end    

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end   
end
