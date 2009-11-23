require File.dirname(__FILE__) + '/../spec_helper'

describe Commitment do
  before(:each) do
    @commitment = Commitment.new commitment_required_values
  end
  
  it "should be valid with #{sentence_of commitment_required_values}" do
    commitment_required_values.keys.each do |a|
      @commitment.send(a).should_not be_nil
    end
    @commitment.should be_valid
  end

  commitment_required_values.keys.each do |a|
    it "should not be valid without #{a}" do
      @commitment.should need(a)
    end
  end

  it "should only allow a commitment level wich is a percentage" do
    [ "asd", 101, -2].each do |value|
      @commitment.level = value
      @commitment.should_not be_valid
    end

    [ 50, 83, 13.52].each do |value|
      @commitment.level = value
      @commitment.should be_valid
    end
  end

  describe "previous" do
    it "should return the previous Commitment for the same User and Project"
    it "should return nil if no User and Sprint is provided"
    it "should return nil if no User is provided"
    it "should return nil if no Sprint is provided"
    it "should return nil if there is no previous Sprint for that project"
    it "should return nil if that User wasn't commited to the previous Sprint"
  end

  describe "next" do
    it "should return the next Commitment for the same User and Project"
    it "should return nil if no User and Sprint is provided"
    it "should return nil if no User is provided"
    it "should return nil if no Sprint is provided"
    it "should return nil if there is no next Sprint for that project"
    it "should return nil if that User wasn't commited to the previous Sprint"
  end

  describe "on intialize" do
    it "should set the same level of the previous Commitment if there is a previous commitment"
    it "should set a level of 100% if there is no previous commitment"

    it "should set a level of 100%" do
      Commitment.new.level.should == 100
    end
  end


  describe "integration" do
    before(:each) do
      @commitment = Commitment.new commitment_required_values
    end

    it "should only allow one commitment for pair User-Sprint" do
      user = User.new user_required_values
      user.save!

      sprint = Sprint.new sprint_required_values
      sprint.save!

      @commitment.sprint = sprint
      @commitment.user = user
      @commitment.save!

      Commitment.new({
        :user => user,
        :sprint => sprint,
        :level => 50
      }).should_not be_valid
    end
  end

  describe "available_hours" do
    it "should return the number of hours that User is commited to that Sprint" do
      @commitment.user.available_hours_per_week = 40
      @commitment.level = 50
      @commitment.sprint.number_of_workdays = 5
      @commitment.available_hours.should == 20 # 40 * 0.5 
    end
  end
end
