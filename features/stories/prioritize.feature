Feature: Prioritize Stories

  So that I can prioritize Stories
  As an Admin
  I want to be able to edit a Story importance

  Scenario: Show inline importance editor
    Given I am logged as user_0
    Given that I am on "Backlog" page under "Project 0"
    Then I should see "Stories"

