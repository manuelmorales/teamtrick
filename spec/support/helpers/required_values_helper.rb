def build_object object_class, new_values={}
  object_class.new send( object_class.to_s.downcase + "_required_values").merge( new_values)
end

def build_mock object_class, new_values={}
  mock_model object_class, send( object_class.to_s.downcase + "_valid_values").merge( new_values)
end

def sentence_of( required_values)
  required_values.keys.to_sentence(:last_word_connector => " and ")
end

def user_required_values
  {
    :login => "john-smith",
    :password => "pink-panther",
    :password_confirmation => "pink-panther",
    :real_name => "John Smith",
    :email => "john@smith.com",
    :available_hours_per_week => 35
  }
end

def user_valid_values
  user_required_values.merge({
    :admin => false,
    :disabled => false,
    :admin? => false,
    :disabled? => false
  })
end

def commitment_required_values
  {
    :user => build_object( User),
    :sprint => build_object( Sprint),
    :level => 83
  }
end

def sprint_required_values
  {
    :start_date => Date.today - 2.days,
    :finish_date => Date.today + 26.days,
    :estimated_focus_factor => 0.7,
    :project => build_object( Project)
  }
end

def story_required_values
  {
    :name => "Implement this new feature",
    :project => build_object( Project),
    :importance => 10
  }
end

def task_required_values
  {
    :name => "Fix computer",
    :story => build_object(Story),
    :original_estimation => 16
  }
end

def planning_required_values
  {
    :sprint => build_object( Sprint),
    :story => build_object(Story)
  }
end

def duty_required_values
  {
    :user => build_object(User),
    :role => build_object(Role),
    :project => build_object(Project)
  }
end

def project_required_values
  {
    :name => "My Project"
  }
end

def role_required_values
  {
    :permalink => "team-member"
  }
end

def work_hour_required_values
  {
    :hours => 15,
    :user => build_object(User),
    :task => build_object(Task),
    :date => Date.today,
    :old_hours_left => 15
  }
end
