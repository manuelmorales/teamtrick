require File.dirname(__FILE__) + '/../spec_helper'

describe WorkHour do
  before(:each) do
    @work_hour = WorkHour.new work_hour_required_values
  end

  it "should be valid with #{sentence_of work_hour_required_values}" do
    work_hour_required_values.keys.each do |a|
      @work_hour.send(a).should_not be_nil
    end
    @work_hour.should be_valid
  end

  work_hour_required_values.keys.each do |a|
    it "should not be valid without #{a}" do
      @work_hour.should need(a)
    end
  end
end

describe "WorkHour integration" do
  fixtures :all

  before(:each) do
    @work_hour = WorkHour.new :hours => 15,
      :user => mock_model(User, "valid?" => true),
      :task => mock_model(Task, "valid?" => true),
      :date => Date.today
  end

  it "should have an Sprint based on its date and Project" do
    # WorkHour from Project 0 Sprint 0
    work_hours(:work_hour_p0_s0_t0_0).sprint.should == sprints(:sprint_p0_0)

    # WorkHour from Project 1 Sprint 0
    work_hours(:work_hour_p1_s0_t0_0).sprint.should == sprints(:sprint_p1_0)

    # WorkHour from Project 1 Sprint 1
    work_hours(:work_hour_p1_s6_t3_0).sprint.should == sprints(:sprint_p1_1)
  end

  it "should have Project through its Story" do
    work_hours(:work_hour_p0_s0_t0_0).project.should == projects(:project_0)
  end

  it "should have Story through its Task" do
    work_hours(:work_hour_p0_s0_t0_0).story.should == stories(:story_p0_0)
  end

  describe "with_project named scope" do
    it "should return all WorkHours for that Project" do
      @project = projects(:project_0)

      WorkHour.with_project(@project).should_not be_nil
      WorkHour.with_project(@project).map(&:project).uniq.first.should == @project
    end

    it "should work with project.id too" do
      @project = projects(:project_0)

      WorkHour.with_project(@project.id).should_not be_nil
      WorkHour.with_project(@project.id).map(&:project).uniq.first.should == @project
    end
  end

  describe "with_date_between named scope" do
    it "should return all WorkHours with field date contained in that range" do
      some_date = Date.parse("Jan, 1 2007") 
      range = some_date..(some_date + 1.days)

      work_hours = WorkHour.with_date_between(range)
      work_hours.should_not be_nil
      work_hours.length.should == 6
      work_hours.each{|wh| range.should include(wh.date)}
    end
  end

  describe "with_task named scope" do
    it "should return all WorkHours associated with that Task" do
      t = tasks(:task_p0_s0_0)

      WorkHour.with_task(t).should_not be_nil
      WorkHour.with_task(t).map(&:task).uniq.first.should == t
    end
  end

  describe "by_date named scope" do
    before :each do
      WorkHour.destroy_all
      date = Date.parse("Jan, 1 2007") 
      @task = Task.first

      attributes = {:hours => 5, :user => User.first, :task => @task, :old_hours_left => 0}
      @wh2 = WorkHour.create attributes.merge(:date => date)
      sleep 1.1
      @wh3 = WorkHour.create attributes.merge(:date => date)
      sleep 1.1
      @wh1 = WorkHour.create attributes.merge(:date => date - 1)
    end

    it "should return WorkHours sorted by date and then by created_at" do
      WorkHour.by_date.map(&:id).should == [@wh1,@wh2,@wh3].map(&:id)
    end

    it "should work when nested too" do
      WorkHour.with_task(@task).by_date.map(&:id).should == [@wh1,@wh2,@wh3].map(&:id)
    end
  end

  describe "on initialize" do
    it "should set yesterday as default date" do
      WorkHour.new.date.should == Date.yesterday
    end
  end
end
