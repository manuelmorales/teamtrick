require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before(:each) do
    @user = User.new(user_required_values)
  end

  it "should be valid with #{sentence_of user_required_values}" do
    user_required_values.keys.each do |a|
      @user.send(a).should_not be_nil
    end
    @user.should be_valid
  end

  user_required_values.keys.each do |a|
    it "should not be valid without #{a}" do
      @user.should need(a)
    end
  end

  [:login, :password, :password_confirmation, :real_name, :email, :available_hours_per_week, :disabled].each do |k|
    it "#{k} should be accessible through mass assignment" do
      User.new k => user_valid_values[k]
      @user.send(k).should eql(user_valid_values[k])
    end
  end

  it "should be Admin or not" do
    @user.should respond_to("admin?")
  end

  it "should be Disabled or not" do
    @user.should respond_to("disabled?")
  end

  it "should be set to Disabled" do
    @user.disabled = true
    @user.should be_valid
  end

  it "should be set to Admin" do
    @user.admin = true
    @user.should be_valid
  end

  it "should have Duties" do
    @user.should respond_to("duties")
  end

  it "should be checked with password" do
    @user.save
    @user.authenticated?("pink-panther").should be_true
  end

  it "done with login and password" do
    @user.save
    User.authenticate( @user.login, @user.password).should == @user
  end

  it "should fail if doesn't match" do
    User.authenticate("blah!","blah!").should be_nil
  end

  it "should reset password" do
    @user.save
    @user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate(@user.login, 'new password').should eql(@user)
  end
  
  it "should not rehash password" do
    @user.save
    @user.update_attributes(:login => 'quentin2')
    User.authenticate('quentin2', 'pink-panther').should eql(@user)
  end

  it "should set remember token" do
    @user.save
    @user.remember_me
    @user.remember_token.should_not be_nil
    @user.remember_token_expires_at.should_not be_nil
  end

  it "should unset remember token" do
    @user.save
    @user.remember_me
    @user.remember_token.should_not be_nil
    @user.forget_me
    @user.remember_token.should be_nil
  end

  it "should have an available_hours_per_week (in hours per week)" do
    @user.should respond_to("available_hours_per_week")
  end

  it "should not allow a non positive integer available_hours_per_week" do
    [ "asd", -2].each do |value|
      @user.available_hours_per_week = value
      @user.should_not be_valid
    end
  end

  it "should not have a default available_hours_per_week of 40 hours per week" do
    User.new.available_hours_per_week.should == 40
  end

  it "should return a random password when called @user.random_password" do
    @user.random_password.should be_a(String)
  end

  describe "interacting with duties" do
    fixtures :all

    before :each do
      @user = users(:default)
      @user.duties.should_not be_nil
    end

    it "should delete them all when disabled through update_attributes" do
      @user.update_attributes :disabled => true
      User.find(@user.id).duties.should be_empty
    end

    it "should delete them all when disabled through save" do
      @user.disabled = true
      @user.save
      User.find(@user.id).duties.should be_empty
    end

    it "should not destroy them when disabled is not true" do
      @user.disabled = false
      @user.save
      User.find(@user.id).duties.should_not be_empty
    end
  end

  describe "projects_to_show" do
    fixtures :all

    before :each do
      @project = Project.create! project_required_values
    end

    it "should return all projects if user is admin" do
      users(:admin).projects_to_show.should include(@project)
    end

    it "should return those projects which the user plays a Role if user is non-admin" do
      users(:any).projects_to_show.should_not include(@project)
    end
  end

  describe "interacting with roles" do
    fixtures :all

    before :each do
      @project = projects(:project_0)
      @user = users(:any)
    end

    it "should find roles by project" do
      @user.roles.with_project(@project).should == [roles(:scrum_master)]
    end

    it "should still respond to  #roles.find_by_permalink" do
      @user.roles.find_by_permalink("scrum_master").should == roles(:scrum_master)
    end

    it "should find duties by project" do
      @user.duties.with_project(@project).should == [duties(:duty_p0_u1)]
    end

    describe "role_for_project" do
      it "should return the corresponding Role for that Project" do
        @user.role_for_project(@project).should == roles(:scrum_master)
      end
    end
  end

  describe "duty_for_project" do
    fixtures :users, :duties, :projects

    it "should return the corresponding Duty for that Project" do
      @project = projects(:project_0)
      @user = users(:any)
      @user.duty_for_project(@project).should == duties(:duty_p0_u1)
    end
  end

  describe "not_present_in named scope" do
  #   fixtures :projects, :users, :roles, :duties

    it "should return users not present in a certain project" # do
  #     u = users(:default)
  #     u.duties.each(&:destroy)
  #     User.not_present_in(projects(:project_0)).should == [u]
  #   end
  #
    it "should not return disabled users"
  end

  describe "enabled named scope" do
    fixtures :users

    it "should return only users with disabled = false" do
      u = users(:default)
      u.update_attributes :disabled => true
      User.enabled.should_not include(u)
    end
  end
end
