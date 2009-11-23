require File.dirname(__FILE__) + '/../spec_helper'

describe Duty do
  before(:each) do
    @record = @duty = Duty.new(duty_required_values)
  end

  it_should_be_valid_with duty_required_values
  it_should_not_be_valid_without duty_required_values

  it "should not have the same User twice per Project" do
    @duty.save

    Duty.new(
      :user => @duty.user, 
      :project => @duty.project, 
      :role => mock_model( Role, "valid?" => true, "unique?" => false)
    ).should_not be_valid
  end

  it "should not have more than one User per Project with Roles marked as \"unique\"" do
    role = mock_model(Role, "valid?" => true, "unique?" => true)
    project = mock_model(Project, "valid?" => true)

    @duty.role = role
    @duty.project = project
    @duty.save

    Duty.new(
      :role => role,
      :user => mock_model(User, "valid?" => true),
      :project => project
    ).should_not be_valid
  end
end
