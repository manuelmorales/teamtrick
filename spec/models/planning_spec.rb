require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Planning do
  before(:each) do
    @planning = Planning.new planning_required_values
  end

  it "should be valid with #{sentence_of planning_required_values}" do
    planning_required_values.keys.each do |a|
      @planning.send(a).should_not be_nil
    end
    @planning.should be_valid
  end

  planning_required_values.keys.each do |a|
    it "should not be valid without #{a}" do
      @planning.should need(a)
    end
  end

  it "should have a date" do
    @planning.should respond_to("date")
  end

  it "should have an \"unexpected\" attribute" do
    @planning.should respond_to('unexpected')
    @planning.should respond_to('unexpected=')
  end

  describe "on initialize" do
    it "should set the \"unexpected\" to \"false\"" do
      Planning.new.unexpected.should be_false
    end

    it "should still set \"unexpected\" when calling new()" do
      Planning.new(:unexpected => true).unexpected.should be_true
    end
  end

  describe "integration" do
    fixtures :all

    before(:each) do
      @planning = plannings :planning_p0_s0
    end

    it "should have original stimation of stories in Plannings" do
      @planning.should_receive("original_estimation=").with(@planning.story.estimation).and_return(true)
      @planning.save
    end

    it "should remain original_estimation untouched" do
      expected_value = @planning.original_estimation

      @planning.story.tasks.first.hours_left = 0
      @planning.story.tasks.first.save

      @planning.original_estimation.should == expected_value
    end
  end
end

