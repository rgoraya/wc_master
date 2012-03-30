require 'spec_helper'

describe "Users" do
  describe "signup" do
    describe "failure" do
      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in "Username",                   :with => ""
          fill_in "Email",                      :with => ""
          fill_in "Password",                   :with => ""
          fill_in "user_password_confirmation", :with => ""
          click_button "Save"
        end.should_not change(User, :count)
      end

    end

  end
end     
