@mod @mod_pulse @mod_pulse_automation @mod_pulse_automation_template @pulseactions @pulseaction_notification @pulseaction_notification_recompletion
Feature: Support recompletion notification action in pulse automation templates
  In order to use the features
  As admin
  I need to be able to configure the pulse automation template
  to reset the notification for recompletion.

  Background:
    Given the following "categories" exist:
      | name  | category | idnumber |
      | Cat 1 | 0        | CAT1     |
    And the following "course" exist:
      | fullname | shortname | category | enablecompletion |
      | Course 1 | C1        | 0        | 1                |
    And the following "users" exist:
      | username | firstname | lastname | email             |
      | student1 | student   | User 1   | student1@test.com |
      | teacher1 | teacher   | User 1   | teacher1@test.com |
    And the following "course enrolments" exist:
      | user     | course | role    |
      | student1 | C1     | student |
      | teacher1 | C1     | teacher |

  @javascript
  Scenario: Verify the recompletion reset the scheduled notification
    Given I log in as "admin"
    And I navigate to automation templates
    And I create pulse notification template "WELCOME MESSAGE" "WELCOMEMESSAGE_" to these values:
      | Sender         | Course teacher                                                                          |
      | Recipients     | Student                                                                                 |
      | Subject        | Welcome to {Site_FullName}                                                              |
      | Header content | Hi {User_firstname} {User_lastname}, <br> Welcome to learning portal of {Site_FullName} |
      | Footer content | Copyright @ 2023 {Site_FullName}                                                        |
    Then I should see "Automation templates"
    And I should see "WELCOME MESSAGE" in the "pulse_automation_template" "table"
    And I navigate to course "Course 1" automation instances
    And I create pulse notification instance "WELCOME MESSAGE" "COURSE_1" to these values:
      | Recipients | Student |
    And I should see "WELCOMEMESSAGE_COURSE_1" in the "pulse_automation_template" "table"
    Then I click on ".action-report#notification-action-report" "css_element" in the "WELCOMEMESSAGE_COURSE_1" "table_row"
    And I switch to a second window
    And ".reportbuilder-report" "css_element" should exist
    And the following should exist in the "reportbuilder-table" table:
      | Full name      | Subject                         | Status |
      | student User 1 | Welcome to Acceptance test site | Queued |
    And I am on "Course 1" course homepage
    When I select "More" from secondary navigation
    And I follow "Course completion"
    And I expand all fieldsets
    And I set the field "Recompletion type" to "On demand"
    And I click on "#id_pulse_1" "css_element"
    And I press "Save changes"
    Then I select "More" from secondary navigation
    And I follow "Modify course completion dates"
    And I should see "student User 1" in the "participants" "table"
    When I click on "#select-all-participants" "css_element"
    And I press "Reset all completion for selected users"
    And I should see "Completion for the selected students in this course has been reset."
    Then I navigate to course "Course 1" automation instances
    And I click on ".action-report#notification-action-report" "css_element" in the "WELCOMEMESSAGE_COURSE_1" "table_row"
    And I switch to a pulse open window
    And the following should not exist in the "reportbuilder-table" table:
      | Full name      | Subject                         | Status |
      | student User 1 | Welcome to Acceptance test site | Queued |
    And I log out
