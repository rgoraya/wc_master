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

  describe "password validations" do
    before(:each) do 
      @user = User.new(@attr)
    end

    it "should have a password attribute" do
      @user.should respond_to(:password)
    end      

    it "should have a password confirmation attribute" do
      @user.should respond_to(:password_confirmation)
    end    
  end

  describe "password validations" do 
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end          

    it "should require a matching password confimration" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end
    
    it "should reject short passwords" do
      short = "a" * 3
      User.new(@attr.merge(:password => short, :password_confirmation => short)).
        should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      User.new(@attr.merge(:password => long, :password_confirmation => long)).
        should_not be_valid
    end    
  end

  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:crypted_password)
    end

    it "should set the encrypted password attribute" do 
      @user.crypted_password.should_not be_blank
    end

    it "should have a password_salt" do 
      @user.should respond_to(:password_salt)
    end
  
    # Now we could test for authentication, password_salt and more stuff 
    # here, but since we didn't use our own authentication but AUTHLOGIC's one,
    # we'll trust how they tested it just like we trust ActiveRecord developer 
    # tests.
  end   
end
