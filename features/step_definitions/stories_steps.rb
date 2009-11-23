Given /^I am logged as (.+)$/ do |user_name|
  visit path_to("the homepage")
  fill_in "login", :with => user_name
  fill_in "password", :with => "pink-panther"
  click_button "Log in"
end

Given /^that I am on "(.+)" page under "(.+)"$/ do |section, project|
  selenium.wait_for_page_to_load(5)
  selenium.click("link=#{project}")

  selenium.wait_for_page_to_load(5)
  selenium.click("link=#{section}")
end


When /^I click "([^\"]*)" link$/ do |text|
  selenium.wait_for_page_to_load(5)
  selenium.click("link=#{text}")
end
