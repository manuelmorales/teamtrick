require File.dirname(__FILE__) + '/../spec_helper'

describe Project do
  before(:each) do
    @project = Project.new project_required_values
  end

  it "should be valid with #{sentence_of project_required_values}" do
    project_required_values.keys.each do |a|
      @project.send(a).should_not be_nil
    end
    @project.should be_valid
  end

  it "should have a description"

  project_required_values.keys.each do |a|
    it "should not be valid without #{a}" do
      @project.should need(a)
    end
  end

  it "should have Sprints" do
    @project.sprints << mock_model(Sprint, "valid?" => true)
    @project.should be_valid
  end

  it "should have Users" do
    @project.should respond_to("users")
  end

  it "should have Stories" do
    @project.stories << mock_model(Story, "valid?" => true)
    @project.should be_valid
  end

  it "should be associated to Users with Roles (Duties)" do
    @project.duties << mock_model(Duty, "valid?" => true)
    @project.should be_valid
  end

  describe "for_user named scope" do
    fixtures :projects, :users, :duties, :roles

    it "should only return Projects where user has a Duty if user is not admin" do
      user = users(:any)
      user.duties.last.destroy
      Project.for_user(user).should == [projects(:project_0)]
    end

    it "should return all Projects if user is admin" do
      user = users(:admin)
      user.duties.destroy_all
      Project.for_user(user).should be_a(Array)
      Project.for_user(user).length.should == 2
    end
  end

  describe "integration with Stories" do
    fixtures :all

    before(:each) do
      @project = projects :project_0
    end

    it "should return Stories sort by importance (descendant)" do
      importance_list = @project.stories.map(&:importance)
      importance_list.should ==  importance_list.sort.reverse 
    end
  end
end

