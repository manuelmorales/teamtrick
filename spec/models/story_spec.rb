require File.dirname(__FILE__) + '/../spec_helper'

describe Story do
  before(:each) do
    @story = Story.new story_required_values
  end

  it "should be valid with #{sentence_of story_required_values}" do
    story_required_values.keys.each do |a|
      @story.send(a).should_not be_nil
    end
    @story.should be_valid
  end

  story_required_values.keys.each do |a|
    it "should not be valid without #{a}" do
      @story.should need(a)
    end
  end
  
  it "should have a description" do
    expected_result = "This is a test."
    @story.description = expected_result
    @story.description.should == expected_result
  end

  it "should have several Tasks" do
    @story.should respond_to("tasks")
  end

  it "should accept Tasks" do
    @task = mock_model(Task)
    @story.tasks << @task
    @story.tasks.should include(@task)
  end

  it "should have an importance value" do
    @story.should respond_to("importance")
    @story.should respond_to("importance=")
  end

  it "should destroy its Tasks when destroyed" do
    @task = mock_model(Task)
    @task.should_receive("destroy")
    @story.tasks << @task
    @story.destroy
  end

  it "should have a storypoints that can be set" do
    @story.storypoints = 15
    @story.storypoints.should == 15
  end

  it "should have hours left based on its Tasks' hours left" do
    @story = Story.new :name => "Implement this!"
    @story.tasks << mock_model( Task, :hours_left => 4 )
    @story.tasks << mock_model( Task, :hours_left => 5 )
    @story.hours_left.should == 9
  end

  it "should have Work Hours based on its Tasks' Work Hours" do
    @story = Story.new :name => "Implement this!"
    wh_1 = mock_model(WorkHour)
    wh_2 = mock_model(WorkHour)
    wh_3 = mock_model(WorkHour)
    task_1 = mock_model( Task, :work_hours => [ wh_1, wh_2])
    task_2 = mock_model( Task, :work_hours => [wh_3])
    @story.tasks << [ task_1, task_2]

    [ wh_1, wh_2, wh_3].each do |wh|
      @story.work_hours.should include(wh)
    end
  end

  describe "when changing importance" do
    fixtures :stories, :projects

    describe "and @story is not valid" do
      before :each do
        @story = stories(:story_p0_2)
        @story.importance = 7
        @story.name = nil
        @story.save
      end

      it "should do nothing" do
        Story.with_project(@story.project).find_by_name("Story number 3").importance.should == 3
      end

      it "should still work when Story is new" do
        @story = Story.new story_required_values
        @story.importance = 27
        @story.save.should be_true
      end
    end

    describe "up" do
      before :each do
        @story = stories(:story_p0_2)
        @story.importance = 7
        @story.save
      end

      it "should save the story successfuly" do
        Story.with_project(@story.project).find_by_name("Story number 2").importance.should == 7
      end

      it "it should lower the importance of all Stories in the middle" do
        Story.with_project(@story.project).find_by_name("Story number 3").importance.should == 2
        Story.with_project(@story.project).find_by_name("Story number 4").importance.should == 3
        Story.with_project(@story.project).find_by_name("Story number 5").importance.should == 4
        Story.with_project(@story.project).find_by_name("Story number 6").importance.should == 5
        Story.with_project(@story.project).find_by_name("Story number 7").importance.should == 6
      end

      it "should leave Stories above untouched" do
        Story.with_project(@story.project).find_by_name("Story number 1").importance.should == 1
        Story.with_project(@story.project).find_by_name("Story number 0").importance.should == 0
      end

      it "should leave Stories behind untouched" do
        Story.with_project(@story.project).find_by_name("Story number 8").importance.should == 8
        Story.with_project(@story.project).find_by_name("Story number 9").importance.should == 9
      end

      it "should leave other Project's Stories untouched" do
        Story.with_project(projects(:project_1)).find_by_name("Story number 4").importance.should == 4
      end
    end
    
    describe "down" do
      before :each do
        @story = stories(:story_p0_7)
        @story.importance = 2
        @story.save
      end

      it "should save the story successfuly" do
        Story.with_project(@story.project).find_by_name("Story number 7").importance.should == 2
      end

      it "it should raise the importance of all Stories in the middle" do
        Story.with_project(@story.project).find_by_name("Story number 2").importance.should == 3
        Story.with_project(@story.project).find_by_name("Story number 3").importance.should == 4
        Story.with_project(@story.project).find_by_name("Story number 4").importance.should == 5
        Story.with_project(@story.project).find_by_name("Story number 5").importance.should == 6
        Story.with_project(@story.project).find_by_name("Story number 6").importance.should == 7
      end

      it "should leave Stories above untouched" do
        Story.with_project(@story.project).find_by_name("Story number 1").importance.should == 1
        Story.with_project(@story.project).find_by_name("Story number 0").importance.should == 0
      end

      it "should leave Stories behind untouched" do
        Story.with_project(@story.project).find_by_name("Story number 8").importance.should == 8
        Story.with_project(@story.project).find_by_name("Story number 9").importance.should == 9
      end

      it "should leave other Project's Stories untouched" do
        Story.with_project(projects(:project_1)).find_by_name("Story number 4").importance.should == 4
      end
    end

    describe "on initialize" do
      fixtures :stories

      it "should set the importance to the maximum" do
        Story.new.importance.should == 11
      end

      it "should set importance to 1 if this is the first story" do
        Story.all.each(&:destroy)
        Story.new.importance.should == 1
      end

      it "should still set importance when calling new" do
        Story.new(:importance => 27).importance.should == 27
      end
    end
  end

  describe "integration with tasks" do
    fixtures :stories, :tasks, :work_hours

    before(:each) do
      @story = stories :story_p0_0
    end

    it "#estimation should return sum of tasks' estimations if there are tasks" do
      # Each story has 4 tasks with an original 
      # stimation of 16
      @story.estimation.should ==  4*16 
    end

    it "should not be completed if its tasks are not completed" do
      @story.completed?.should == false
    end

    it "should be completed if its tasks are completed" do
      @story.tasks.each{|t| t.hours_left = 0 }
      @story.completed?.should == true
    end

    it "should not be completed if it has no tasks" do
      @story.tasks.each{|t| t.destroy }
      @story.completed?.should == false
    end

    it "should have hours_left based on its tasks" do
      @story.hours_left.should ==  4*16 

      @story.tasks.first.hours_left = 0
      @story.hours_left.should ==  3*16 
    end

    it "should return nil when asked for hours_left if it has no tasks" do
      @story.tasks.each{|t| t.destroy }
      @story.reload.hours_left.should == nil
    end

    describe "named scope completed" do
      before :each do
        @stories = Story.completed
      end
        
      it "should return stories with hours_left == 0" do
        @stories.length.should == 10
        @stories.map(&:completed?).uniq.should == [true]
      end

      it "should not return stories with no tasks" do
        @story = Story.create(story_required_values)
        Story.completed.should_not include(@story)
      end
    end

    describe "named scope uncompleted" do
      before :each do
        @stories = Story.uncompleted
      end
        
      it "should return stories with hours_left != 0" do
        @stories.length.should == 22
        @stories.map(&:completed?).uniq.should == [false]
      end

      it "should return stories with no tasks" do
        @story = Story.create story_required_values
        Story.uncompleted.should include(@story)
      end
    end
  end
end

