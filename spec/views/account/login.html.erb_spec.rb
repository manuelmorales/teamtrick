require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/account/login.html.erb" do
  include UsersHelper
  
  before(:each) do
  end

  it "should render login form" do
    render "/account/login.html.erb"
    
    response.should have_tag("form[action=#{"/login"}][method=post]") do
      with_tag('input#login[name=login]')
      with_tag('input#password[name=password]')
      with_tag('input#remember_me[name=remember_me]')
    end
  end
end


