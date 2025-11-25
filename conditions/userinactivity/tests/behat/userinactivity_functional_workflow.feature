@mod @mod_pulse @pulse_triggercondition @pulsecondition_userinactivity @javascript
Feature: User inactivity trigger condition - Functional workflow tests
  In order to monitor student engagement and send timely notifications
  As a teacher or admin
  I need to verify that user inactivity conditions trigger notifications correctly based on student behavior

  Background:
    Given the following "course" exist:
      | fullname | shortname | category | enablecompletion |
      | Course 1 | C1        | 0        | 1                |
    And the following "activities" exist:
      | activity | name        | course | idnumber | completion |
      | assign   | Assign1     | C1     | assign1  | 1          |
      | assign   | Assign2     | C1     | assign2  | 1          |
      | forum    | Forum1      | C1     | forum1   | 1          |
      | page     | TestPage 01 | C1     | page1    | 1          |
    And the following "users" exist:
      | username | firstname | lastname | email             |
      | student1 | Student   | User 1   | student1@test.com |
      | student2 | Student   | User 2   | student2@test.com |
      | student3 | Student   | User 3   | student3@test.com |
      | teacher1 | Teacher   | User 1   | teacher1@test.com |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | C1     | editingteacher |
      | student1 | C1     | student        |
      | student2 | C1     | student        |
      | student3 | C1     | student        |
    And I log in as "admin"
    And I am on "Course 1" course homepage
    And I navigate to "Settings" in current page administration
    And I expand all fieldsets
    And I set the field "Enable completion tracking" to "Yes"
    And I press "Save and display"
    And I click on "More" "link" in the ".secondary-navigation" "css_element"
    And I click on "Course completion" "link" in the ".secondary-navigation" "css_element"
    And I expand all fieldsets
    And I set the following fields to these values:
      | Assign1     | 1 |
      | Assign2     | 1 |
      | Forum1      | 1 |
      | TestPage 01 | 1 |
    And I press "Save changes"

  Scenario: User inactivity based on course access - Verify notification sent only to inactive users
    # Create automation template with notification
    Given I create automation template with the following fields to these values:
      | Title     | Access Inactivity Alert |
      | Reference | accessalert             |
    # Configure instance with condition and notification
    And I am on "Course 1" course homepage
    And I follow "Automation"
    When I open the autocomplete suggestions list
    And I click on "Access Inactivity Alert" item in the autocomplete list
    Then I press "Add automation instance"
    And I set the following fields to these values:
      | insreference | accessinactive1 |
    # Configure inactivity condition - 5 minutes of no course access
    Then I follow "Condition"
    And I click on "#id_override_condition_userinactivity_status" "css_element"
    And I set the field "condition[userinactivity][status]" to "All"
    And I click on "#id_override_condition_userinactivity_type" "css_element"
    And I set the field "condition[userinactivity][type]" to "Based on access"
    And I click on "#id_override_condition_userinactivity_inactivityperiod" "css_element"
    And I set the field "condition[userinactivity][inactivityperiod][number]" to "5"
    And I set the field "condition[userinactivity][inactivityperiod][timeunit]" to "minutes"
    # Configure notification action
    And I click on "Notification" "link" in the "#automation-tabs" "css_element"
    And I click on "#id_override_pulsenotification_actionstatus" "css_element"
    And I set the field "id_pulsenotification_actionstatus" to "Enabled"
    And I click on "#id_override_pulsenotification_sender" "css_element"
    And I set the field "pulsenotification_sender" to "Course teacher"
    # And I click on "#id_override_pulsenotification_recipients" "css_element"
    # And I open the autocomplete suggestions list in the "#fitem_id_pulsenotification_recipients" "css_element"
    # And I click on "Student" item in the autocomplete list

    And I click on "#id_override_pulsenotification_recipients" "css_element" in the "#fitem_id_pulsenotification_recipients" "css_element"
    And I open the autocomplete suggestions list in the "#fitem_id_pulsenotification_recipients" "css_element"
    And I click on "Student" item in the autocomplete list

    And I click on "#id_override_pulsenotification_subject" "css_element"
    And I set the field "pulsenotification_subject" to "Course Access Reminder"
    And I click on "#id_override_pulsenotification_headercontent_editor" "css_element"
    And I set the field "pulsenotification_headercontent_editor[text]" to "Hi {User_firstname}, you haven't accessed the course recently."
    And I press "Save changes"
    # Simulate student2 accessing the course (active user)
    And I log out
    And I log in as "student2"
    And I am on "Course 1" course homepage
    And I wait "2" seconds
    And I log out
    # Wait for inactivity period (student1 remains inactive)
    And I wait "10" seconds
    # Run scheduled task to check inactivity and trigger notifications
    And I log in as "admin"
    And I run all adhoc tasks
    # Verify notification report
    And I am on "Course 1" course homepage
    And I follow "Automation"
    And I click on "#notification-action-report" "css_element" in the "Access Inactivity Alert" "table_row"
    And I switch to a second window
    # Student1 should have notification queued (inactive - no access)
    And the following should exist in the "reportbuilder-table" table:
      | Full name      | Subject                 | Status |
      | Student User 1 | Course Access Reminder  | Queued |
    # Student2 should NOT have notification (active - accessed course)
    And the following should not exist in the "reportbuilder-table" table:
      | Full name      | Subject                 |
      | Student User 2 | Course Access Reminder  |
    And I close all opened windows

  Scenario: User inactivity based on activity completion - Verify notification based on completion behavior
    # Create automation template
    Given I create automation template with the following fields to these values:
      | Title     | Completion Inactivity Alert |
      | Reference | completionalert             |
    # Configure instance
    And I am on "Course 1" course homepage
    And I follow "Automation"
    When I open the autocomplete suggestions list
    And I click on "Completion Inactivity Alert" item in the autocomplete list
    Then I press "Add automation instance"
    And I set the following fields to these values:
      | insreference | completioninactive1 |
    # Configure condition - 5 minutes without activity completion
    Then I follow "Condition"
    And I click on "#id_override_condition_userinactivity_status" "css_element"
    And I set the field "condition[userinactivity][status]" to "All"
    And I click on "#id_override_condition_userinactivity_type" "css_element"
    And I set the field "condition[userinactivity][type]" to "Based on activity completion"
    And I click on "#id_override_condition_userinactivity_includedactivities" "css_element"
    And I set the field "condition[userinactivity][includedactivities]" to "All activities"
    And I click on "#id_override_condition_userinactivity_inactivityperiod" "css_element"
    And I set the field "condition[userinactivity][inactivityperiod][number]" to "5"
    And I set the field "condition[userinactivity][inactivityperiod][timeunit]" to "minutes"
    # Configure notification
    And I click on "Notification" "link" in the "#automation-tabs" "css_element"
    And I click on "#id_override_pulsenotification_actionstatus" "css_element"
    And I set the field "id_pulsenotification_actionstatus" to "Enabled"
    And I click on "#id_override_pulsenotification_sender" "css_element"
    And I set the field "pulsenotification_sender" to "Course teacher"
    And I click on "#id_override_pulsenotification_recipients" "css_element" in the "#fitem_id_pulsenotification_recipients" "css_element"
    And I open the autocomplete suggestions list in the "#fitem_id_pulsenotification_recipients" "css_element"
    And I click on "Student" item in the autocomplete list

    # And I click on "#id_override_pulsenotification_recipients" "css_element"
    # And I open the autocomplete suggestions list in the "#fitem_id_pulsenotification_recipients" "css_element"
    # And I click on "Student" item in the autocomplete list
    And I click on "#id_override_pulsenotification_subject" "css_element"
    And I set the field "pulsenotification_subject" to "Complete Activities Reminder"
    And I click on "#id_override_pulsenotification_headercontent_editor" "css_element"
    And I set the field "pulsenotification_headercontent_editor[text]" to "Hi {User_firstname}, please complete course activities."
    And I press "Save changes"
    # Simulate student2 completing activities (active user)
    And I log out
    And I log in as "student2"
    And I am on "Course 1" course homepage
    And I click on "Mark as Done" "button" in the ".section .activity:first-child" "css_element"
    And I click on "Mark as Done" "button" in the ".section .activity:nth-child(2)" "css_element"
    And I log out
    # Wait for inactivity period
    And I wait "10" seconds
    # Run scheduled task
    And I log in as "admin"
    And I run all adhoc tasks
    # Verify notification report
    And I am on "Course 1" course homepage
    And I follow "Automation"
    And I click on "#notification-action-report" "css_element" in the "Completion Inactivity Alert" "table_row"
    And I switch to a second window
    # Student1 should have notification (inactive - no completions)
    And the following should exist in the "reportbuilder-table" table:
      | Full name      | Subject                        | Status |
      | Student User 1 | Complete Activities Reminder   | Queued |
    # Student2 should NOT have notification (active - completed activities)
    And the following should not exist in the "reportbuilder-table" table:
      | Full name      | Subject                      |
      | Student User 2 | Complete Activities Reminder |
    # Student3 should also have notification (inactive)
    And the following should exist in the "reportbuilder-table" table:
      | Full name      | Subject                        | Status |
      | Student User 3 | Complete Activities Reminder   | Queued |
    And I close all opened windows
