require File.dirname(__FILE__) + '/../spec_helper'

describe Role do
  fixtures :roles

  before(:each) do
    @role = Role.new role_required_values
  end

  it "should be valid with #{sentence_of role_required_values}" do
    role_required_values.keys.each do |a|
      @role.send(a).should_not be_nil
    end
    @role.should be_valid
  end

  role_required_values.keys.each do |a|
    it "should not be valid without #{a}" do
      @role.should need(a)
    end
  end

  it "has a list of possible permalinks" do
    Role.possible_permalinks.should be_kind_of(Array)
  end

  it "should not be valid with permalink not in the list of possible permalinks" do
    @role.permalink = "blahblah"
    @role.valid?.should be_false
  end

  MANDATORY_PERMALINKS_LIST = %w{
    scrum-master
    product-owner
    team-member
    guest
  }

  MANDATORY_PERMALINKS_LIST.each do |p|
    it "permalink \"#{p}\" should be valid" do
      @role.permalink = p
      @role.valid?.should be_true
    end
  end

  it "has a name" do
    @role.should respond_to "name"
  end

  it "should be unique per project or not" do
    @role.should respond_to("unique?")
  end

  it "should return the Scrum Master Role when called Role.scrum_master" do
    Role.scrum_master.should_not be_nil
    Role.scrum_master.name.should == "Scrum Master"
  end

  it "should return the Team Member Role when called Role.team_member" do
    Role.team_member.should_not be_nil
    Role.team_member.name.should == "Team Member"
  end

  it "should return the Product Owner Role when called Role.product_owner" do
    Role.product_owner.should_not be_nil
    Role.product_owner.name.should == "Product Owner"
  end
end
