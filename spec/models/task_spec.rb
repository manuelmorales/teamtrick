require File.dirname(__FILE__) + '/../spec_helper'

describe Task do
  before(:each) do
    @task = Task.new task_required_values
  end

  it "should be valid with #{sentence_of task_required_values}" do
    task_required_values.keys.each do |a|
      @task.send(a).should_not be_nil
    end
    @task.should be_valid
  end

  task_required_values.keys.each do |a|
    it "should not be valid without #{a}" do
      @task.should need(a)
    end
  end
  
  it "should have a description" do
    expected_result = "This is a test."
    @task.description = expected_result
    @task.description.should == expected_result
  end

  it "should have an original estimation that can be set" do
    @task.original_estimation = 17
    @task.original_estimation.should == 17
  end

  it "should have several Work Hours" do
    @task.should respond_to("work_hours")
  end

  it "should accept Work Hours" do
    @work_hour = mock_model(WorkHour)
    @task.work_hours << @work_hour
    @task.work_hours.should include(@work_hour)
  end

  it "should destroy its Work Hours when destroyed" do
    @work_hour = mock_model(WorkHour)
    @work_hour.should_receive("destroy")
    @task.work_hours << @work_hour
    @task.destroy
  end

  it "should have hours left" do
    @task.should respond_to("hours_left")
  end

  it "should assign original_estimation to hours_left on save" do
    task_required_values.should_not have_key(:hours_left)
    t = build_object(Task)
    t.save
    t.reload
    t.hours_left.should == task_required_values[:original_estimation]
  end

  it "should keep forced hours_left on save" do
    t = build_object(Task, :hours_left => 10)
    t.save
    t.reload
    t.hours_left.should == 10
  end

  describe "project" do
    fixtures :tasks, :stories, :projects

    it "should return its Story's Project" do
      tasks(:task_p0_s0_0).project.should == projects(:project_0)
    end
  end

  describe "hours_left_for_day(d)" do
    fixtures :tasks, :stories, :projects

    before :each do
      WorkHour.destroy_all
      @d = Date.parse("Jan, 1 2007") 
      @task = Task.first
      @task.update_attribute :hours_left, 0
    end

    it "should return its own hours_left when no WorkHour is present" do
      @task.hours_left_for_day(@d).should == 0
    end

    it "should return old_hours_left of the first WorkHour with date before d" do
      attributes = {:hours => 5, :user => User.first, :task => @task}
      @wh2 = WorkHour.create attributes.merge(:date => @d, :old_hours_left => 50)
      sleep 1.1
      @wh3 = WorkHour.create attributes.merge(:date => @d, :old_hours_left => 25)
      sleep 1.1
      @wh1 = WorkHour.create attributes.merge(:date => @d - 1, :old_hours_left => 100)

      @task.hours_left_for_day(@d - 2).should == 100
      @task.hours_left_for_day(@d - 1).should == 100
      @task.hours_left_for_day(@d).should == 50
      @task.hours_left_for_day(@d + 1).should == 0
    end

    it "should not return new_hours_left of any other Task's WorkHour" do
      task_0 = tasks(:task_p0_s0_0)
      task_1 = tasks(:task_p0_s0_1)
      attributes = {:hours => 5, :user => User.first, :date => @d, :old_hours_left => 2}
      
      wh0 = WorkHour.create attributes.merge(:task => task_0, :old_hours_left => 0)
      wh1 = WorkHour.create attributes.merge(:task => task_1, :old_hours_left => 1)

      task_0.hours_left_for_day(@d).should == 0
    end
  end
end
