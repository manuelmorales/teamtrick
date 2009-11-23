require File.dirname(__FILE__) + '/../spec_helper'

describe Sprint do
  include SprintHelpers

  before(:each) do
    @sprint = Sprint.new sprint_required_values
  end

  it "should be valid with #{sentence_of sprint_required_values}" do
    sprint_required_values.keys.each do |a|
      @sprint.send(a).should_not be_nil
    end
    @sprint.should be_valid
  end

  sprint_required_values.keys.each do |a|
    it "should not be valid without #{a}" do
      @sprint.should need(a)
    end
  end

  it "should have a number_of_workdays" do
    @sprint.should respond_to("number_of_workdays")
  end

  it "should check that number_of_workdays are non-zero positive integers" do
    [0, -1, -88, 5.3, "asd"].each do |wd|
      @sprint.number_of_workdays = wd
      @sprint.should_not be_valid
    end
  end

  it "should auto calculate number_of_workdays if not given" do
    @sprint.start_date = Date.parse("January, 1, 2007")
    @sprint.finish_date = Date.parse("January, 3, 2007")
    @sprint.number_of_workdays.should be(3)
  end

  it "should calculate number_of_workdays taking care of the day of the week" do
    @sprint.start_date = Date.parse("January, 1, 2007")
    @sprint.finish_date = Date.parse("January, 8, 2007")
    @sprint.number_of_workdays.should be(6)
  end

  it "should let number_of_workdays to be set by hand" do
    wd = 10
    @sprint.number_of_workdays = wd
    @sprint.number_of_workdays.should be(wd)
  end

  it "should not be valid if start_date is higher than finish_date" do
    @sprint.start_date = Date.today - 1.week
    @sprint.finish_date = Date.today - 2.weeks
    @sprint.should_not be_valid
  end

  it "should not be valid if start_date is equal than finish_date" do
    date = Date.today - 1.week
    @sprint.start_date = date
    @sprint.finish_date = date
    @sprint.should_not be_valid
  end

  it "should be valid even if there is a sprint before" do
    existent_sprint = Sprint.new sprint_required_values
    existent_sprint.start_date = Date.today - 8.weeks
    existent_sprint.finish_date = Date.today - 6.weeks
    existent_sprint.save

    conflicting_sprint = Sprint.new sprint_required_values
    conflicting_sprint.start_date = Date.today - 16.weeks
    conflicting_sprint.finish_date = Date.today - 14.weeks
    conflicting_sprint.should be_valid
  end

  it "should not check dates against itself when looking for date conflicts" do
    existent_sprint = Sprint.new sprint_required_values
    existent_sprint.project = Project.new project_required_values
    existent_sprint.save!
    s = Sprint.find existent_sprint.id
    s.should be_valid
  end

  it "should not be valid if it overlaps an existent Sprint" do
    existent_sprint = Sprint.new sprint_required_values
    conflicting_sprint = Sprint.new sprint_required_values
    existent_sprint.project = conflicting_sprint.project
    existent_sprint.save

    check_all_overlapping_possibilities_for( existent_sprint, conflicting_sprint) do |conflicting_sprint| 
      conflicting_sprint.should_not be_valid
      conflicting_sprint.errors.first.should_not be_nil
    end
  end

  it "should be valid if it overlaps an existent Sprint from another project" do
    existent_sprint = Sprint.new sprint_required_values
    existent_sprint.project = Project.create project_required_values
    existent_sprint.save

    check_all_overlapping_possibilities_for(existent_sprint){|conflicting_sprint| conflicting_sprint.should be_valid}
  end

  it "should have a duration in days" do
    @sprint.start_date = Date.today - 5.weeks
    @sprint.finish_date = Date.today - 1.weeks
    @sprint.duration.should == 4*7
  end

  it "should return a status of \"closed\" if finish_date has already passed" do
    @sprint.start_date = Date.today - 5.weeks
    @sprint.finish_date = Date.today - 1.weeks
    @sprint.status.should == "closed"
  end

  it "should return a status of \"planning\" if start_date hasn't arrived yet, even if it already has Plannings" do
    @sprint.plannings = [ mock_model Planning, :valid => true ]
    @sprint.start_date = Date.today + 5.weeks
    @sprint.finish_date = Date.today + 9.weeks
    @sprint.status.should == "planning"
  end

  it "should return a status of \"planning\" if start_date hasn't arrived and it still has no Plannings " do
    @sprint.start_date = Date.today - 5.weeks
    @sprint.finish_date = Date.today + 2.days
    @sprint.status.should == "planning"
  end

  it "should return a status of \"planning\" if start_date isn't set yet " do
    @sprint.start_date = nil
    @sprint.finish_date = Date.today + 2.days
    @sprint.status.should == "planning"
  end

  it "should return a status of \"in_course\" if start_date has arrived and has Plannings " do
    @sprint.plannings = [ mock_model Planning, :valid => true ]
    @sprint.start_date = Date.today - 5.weeks
    @sprint.finish_date = Date.today + 2.days
    @sprint.status.should == "in_course"
  end
end

describe "Sprint integration" do
  fixtures :all

  before(:each) do
    @sprint = sprints :sprint_p0_0
  end

  it "should have level of commitment for each User" do
    c = @sprint.commitments
    c.length.should == 3
    c.should include( commitments :commitment_u1_p0_s0)
  end

  it "should have available_hours depending on Commitments" do
    # Users 0..2 are commited at a level of 50
    # available_hours_per_week is 40
    # expected_result = number_of_users * available_hours_per_workday * workdays * commitment_level
    @sprint.available_hours.should ==  (3 * 8 * 20 * 0.5).to_i 
  end

  it "should have WorkHours based on their dates" do
    wh = @sprint.work_hours
    # on fixtures we created 3 work_hours per day
    wh.length.should == @sprint.duration * 3
    wh.should include( work_hours :work_hour_p0_s0_t0_0)
  end

  it "should have a work_hours_sum" do
    @sprint.work_hours_sum.should == @sprint.duration * 3 * 5
  end

  describe "#focus_factor" do
    it "should return the real Focus Factor based on WorkHours and available_hours (only for closed Sprints)" do
      # available_hours / work_hours
      expected_focus_factor =  (3 * 8 * 20 * 0.5) / (@sprint.duration * 3 * 5)
      @sprint.focus_factor.should ==  expected_focus_factor
    end

    it "should return nil if Sprint is not closed" do
      Sprint.new.focus_factor.should be_nil
    end
  end

  it "should only return WorkHours that matches its Sprint" do
    wh = @sprint.work_hours
    wh.map{|w| w.project}.uniq.length.should == 1
  end

  it "should have worked_on_stories based on WorkHours if it is closed" do
    wos = @sprint.worked_on_stories

    # WorkHours have been created for
    # each task of the stories 0..6.
    wos.length.should == 7
  end

  it "should have Plannings" do
    pl = @sprint.plannings
    pl.length.should == 10
    pl.should include(plannings :planning_p0_s0)
  end

  it "should have a Planning date based on  its first Planning" do
    @sprint.planning_date.should == Date.parse("Jan, 1, 2007")
  end

  it "should have stories through Plannings" do
    st = @sprint.stories
    st.length.should == 10
    st.should include(stories :story_p0_0)
  end

  it "should have unplanned_stories based on the date of planning" do
    @sprint.unplanned_stories.should ==  [ stories :story_p0_9 ] 
  end

  describe "#factible_stories" do
    it "should not sum more hours than available_hours" do
      @sprint.factible_stories.sum{|s| s.hours_left.to_i }.should <= @sprint.available_hours
    end

    it "should be sort by importance" do
      importance_list = @sprint.factible_stories.map(&:importance)
      importance_list.should ==  importance_list.sort.reverse 
    end

    it "should return the most important Stories" do
      minimum_importance = @sprint.factible_stories.last.importance
      non_factible_stories = (@sprint.project.stories - @sprint.factible_stories).reject{|s| s.hours_left == 0}

      non_factible_stories.select{|s| s.importance > minimum_importance}.should be_empty
    end

    it "should not include finished Stories" do
      factible_stories_list_before = @sprint.factible_stories
      factible_stories_list_before.last.tasks.each{|t| t.hours_left = 0; t.save!}

      @sprint.factible_stories.should_not include(factible_stories_list_before.last)
    end

    it "should return stories so that, the next non-factible story doesn't fit on available_hours" do
      non_factible_stories = (@sprint.project.stories - @sprint.factible_stories).reject{|s| s.hours_left == 0}
      non_factible_stories.should_not be_nil # For this test to make sense

      (@sprint.factible_stories.sum{|s| s.hours_left.to_i } + non_factible_stories.first.hours_left).should > @sprint.available_hours
    end

    it "should not reject the las Story unless the last Story doesn't fit on available_hours" do
      original_factible_stories = @sprint.factible_stories
      non_factible_stories = (@sprint.project.stories - @sprint.factible_stories)
      non_factible_stories.each(&:destroy)

      @sprint.factible_stories.length.should == original_factible_stories.length
    end
  end

  describe "iteration" do
    it "should return the iteration number that Sprint is" do
      sprints(:sprint_p0_0).iteration.should == 1
      sprints(:sprint_p0_1).iteration.should == 2
    end
  end

  describe "team_velocity" do
    before :each do
      @sprint = sprints(:sprint_p0_0)
    end

    it "should return the sum of storypoints of completed Stories for that Sprint" do
      velocity = @sprint.team_velocity
      velocity.should_not be_nil
      velocity.should == @sprint.plannings.map{|p| p.story.completed? ? p.story.storypoints : 0}.sum
    end
  end
  
  describe "generate_plannings" do
    it "should generate plannings based on factible_stories" do
      @sprint = Sprint.create :start_date => Date.today - 1.weeks,
        :finish_date => Date.today + 1.weeks,
        :estimated_focus_factor => 0.7,
        :project => projects(:project_0)

      @sprint.generate_plannings.should be_true

      @sprint.plannings.should_not be_nil
      @sprint.plannings.map(&:story).sort_by(&:importance).should == @sprint.stories.sort_by(&:importance)
    end
  end

  describe "ideal_hours_left" do
    it "should return the sum of its Planning's original_estimation" do
      sprints(:sprint_p0_0).ideal_hours_left.should == 160
    end
  end

  describe "ideal_hours_left_for_day(d)" do
    it "should be zero for 2 days after the last day" do
      s = sprints(:sprint_p0_0)
      s.ideal_hours_left_for_day(s.finish_date + 2).should == 0
    end

    it "should be == ideal_hours_left for the first day" do
      s = sprints(:sprint_p0_0)
      s.ideal_hours_left_for_day(s.start_date).should ==  s.ideal_hours_left
    end

    it "should be == ideal_hours_left for days before the first day" do
      s = sprints(:sprint_p0_0)
      s.ideal_hours_left_for_day(s.start_date - 1).should ==  s.ideal_hours_left
    end

    it "should return its ideal_hours_left for a certain day" do
      @sprint = sprints(:sprint_p0_0)
      d = @sprint.finish_date
      @sprint.ideal_hours_left_for_day(d).should == 160.to_f / (@sprint.duration + 1)
    end
  end

  describe "hours_left_for_day(d)" do
    before :each do
      @sprint = sprints(:sprint_p0_0)
      @sprint.plannings.destroy_all
      [stories(:finished_story_p0_0), stories(:finished_story_p0_1)].each do |s|
        Planning.create :story => s, :sprint => @sprint, :original_estimation => 0 
      end

      WorkHour.destroy_all

      @sprint.reload.plannings.map(&:story).map(&:tasks).flatten.each do |t|
        WorkHour.create :date => @sprint.start_date + 2,
          :old_hours_left => 50,
          :hours => 5,
          :user => User.first,
          :task => t
      end
    end

    it "should return the sum of its Tasks' hours_left_for_day(d)" do
      @sprint.hours_left_for_day(@sprint.start_date).should == 100
      @sprint.hours_left_for_day(@sprint.finish_date).should == 0
    end

    it "should not return nil if day d the day after today" do
      @sprint.hours_left_for_day(Date.today + 1).should_not be_nil
    end

    it "should return nil if day d is later than the day after today" do
      @sprint.hours_left_for_day(Date.today + 2).should be_nil
    end
  end
end
