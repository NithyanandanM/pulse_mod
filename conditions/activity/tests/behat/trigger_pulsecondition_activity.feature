@mod @mod_pulse @pulse_triggercondition @pulsecondition_activity @javascript
Feature: Activity trigger event.
  In To Verify Pulse Automation Template Conditions for Activity as a Teacher.

  Background:
    Given the following "course" exist:
      | fullname | shortname | category | enablecompletion |
      | Course 1 | C1        | 0        | 1                |
    And the following "activities" exist:
      | activity | name        | course | idnumber | completion |
      | assign   | Assign1     | C1     | assign1  | 1          |
      | assign   | Assign2     | C1     | assign2  | 1          |
      | forum    | Forum1      | C1     | forum1   | 1          |
      | forum    | Forum2      | C1     | forum2   | 1          |
      | page     | TestPage 01 | C1     | page1    | 1          |
      | page     | TestPage 02 | C1     | page2    | 1          |
    And the following "users" exist:
      | username | firstname | lastname | email             |
      | student1 | student   | User 1   | student1@test.com |
      | teacher1 | Teacher   | User 1   | teacher1@test.com |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | C1     | editingteacher |
      | student1 | C1     | student        |

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
      | Assign1       | 1 |
      | Assign2       | 1 |
      | Forum1        | 1 |
      | Forum2        | 1 |
      | TestPage 01   | 1 |
      | TestPage 02   | 1 |
    And I press "Save changes"

    Then I create automation template with the following fields to these values:
      | Title     | Template1 |
      | Reference | temp1     |
    And I click on "Create new template" "button"
    Then I set the following fields to these values:
      | Title     | Notification1 |
      | Reference | notification1 |
    And I press "Save changes"

  Scenario: Check the pluse condition activity trigger workflow
    Given I log in as "admin"
    Then I create automation template with the following fields to these values:
      | Title     | WELCOME MESSAGE 01 |
      | Reference | Welcomemessage     |
    Then I create automation template with the following fields to these values:
      | Title     | WELCOME MESSAGE 02 |
      | Reference | Welcomemessage02   |
    Then I create "Welcomemessage" template with the set the condition:
      | Activity completion | All |
      | Trigger operator    | All |
    And I am on "Course 1" course homepage
    And I follow "Automation"
    When I open the autocomplete suggestions list
    And I click on "WELCOME MESSAGE 01" item in the autocomplete list
    Then I press "Add automation instance"
    And I set the following fields to these values:
      | insreference | Welcomemessage |
    Then I follow "Condition"
    Then I should see "Activity completion"
    Then the field "Activity completion" matches value "All"
    And I should see "Select activities"
    Then I click on "#fitem_id_condition_activity_modules .form-autocomplete-downarrow" "css_element"
    Then I should see "TestPage 01" in the "#fitem_id_condition_activity_modules .form-autocomplete-suggestions" "css_element"
    Then I should see "TestPage 02" in the "#fitem_id_condition_activity_modules .form-autocomplete-suggestions" "css_element"
    And I press "Save changes"
    When I open the autocomplete suggestions list
    And I click on "WELCOME MESSAGE 02" item in the autocomplete list
    Then I press "Add automation instance"
    And I set the following fields to these values:
      | insreference | Welcomemessage2 |
    Then I follow "Condition"
    Then I should see "Activity completion"
    And I should not see "Select activities"
    Then the field "Activity completion" matches value "Disable"
    Then I wait "5" seconds
    Then I click on "input[name='override[condition_activity_status]'].checkboxgroupautomation" "css_element"
    And I set the field "Activity completion" to "All"
    And I should see "Select activities"
    And I press "Save changes"

  Scenario: Activity completion condition - Enhance settings
    And I am on "Course 1" course homepage
    And I navigate to "Automation" in current page administration
    And I wait until the page is ready
    And I open the autocomplete suggestions list
    And I click on "Template1" item in the autocomplete list
    And I click on "Add automation instance" "button" in the ".template-add-form" "css_element"
    And I set the field "insreference" to "temp1"
    And I click on "#id_override_frequencylimit" "css_element" in the "#fitem_id_frequencylimit" "css_element"
    And I set the field "frequencylimit" to "1"
    And I press "Save changes"

    # Check the schedule for the instance
    And I click on "#notification-action-report" "css_element" in the "Template1" "table_row"
    And I switch to a second window
    And I should see "Nothing to display" in the ".reportbuilder-wrapper" "css_element"
    And I close all opened windows

    # Instance Conditions - Activity completion
    And I click on ".action-edit" "css_element" in the "Template1" "table_row"
    Then I follow "Condition"
    And I click on "#id_override_triggeroperator" "css_element" in the "#pulse-condition-tab" "css_element"
    Then the field "Trigger operator" matches value "All"
    And I click on "#id_override_condition_activity_status" "css_element" in the "#fitem_id_condition_activity_status" "css_element"
    And I set the field "condition[activity][status]" to "All"
    And I click on "#id_override_condition_activity_modules" "css_element" in the "#fitem_id_condition_activity_modules" "css_element"
    And I set the field "Select activities" in the "#fitem_id_condition_activity_modules" "css_element" to "Assign1, Assign2, Forum1, Forum2, TestPage 01, TestPage 02"
    And I click on "#id_override_condition_activity_acompletionmethod" "css_element" in the "#fitem_id_condition_activity_acompletionmethod" "css_element"
    And I set the field "condition[activity][acompletionmethod]" to "Activity count"
    And I click on "#id_override_condition_activity_activitycount" "css_element" in the "#fitem_id_condition_activity_activitycount" "css_element"
    And I set the field "condition[activity][activitycount]" to "4"
    And I click on "#id_override_condition_activity_completionstatus" "css_element" in the "#fitem_id_condition_activity_completionstatus" "css_element"
    And I set the field "condition[activity][completionstatus]" to "Completed"

    # Instance Notifications
    And I click on "Notification" "link" in the "#automation-tabs" "css_element"
    And I click on "#id_override_pulsenotification_actionstatus" "css_element" in the "#fitem_id_pulsenotification_actionstatus" "css_element"
    And I set the field "id_pulsenotification_actionstatus" to "Enabled"
    And I click on "#id_override_pulsenotification_sender" "css_element" in the "#fitem_id_pulsenotification_sender" "css_element"
    And I set the field "pulsenotification_sender" to "Course teacher"
    And I click on "#id_override_pulsenotification_recipients" "css_element" in the "#fitem_id_pulsenotification_recipients" "css_element"
    And I open the autocomplete suggestions list in the "#fitem_id_pulsenotification_recipients" "css_element"
    And I click on "Teacher" item in the autocomplete list

    And I click on "#id_override_pulsenotification_subject" "css_element" in the "#fitem_id_pulsenotification_subject" "css_element"
    And I set the field "pulsenotification_subject" to "Activity  completion notification"
    And I click on "#id_override_pulsenotification_headercontent_editor" "css_element" in the "#fitem_id_pulsenotification_headercontent_editor" "css_element"
    And I click on "#header-email-vars-button" "css_element" in the ".mod-pulse-emailvars-toggle" "css_element"
    And I click on pulse "id_pulsenotification_headercontent_editor" editor
    And I click on "#Firstname" "css_element" in the ".Sender_field-placeholders" "css_element"
    And I press "Save changes"

    # Check the schedule for the instance for No group
    And I click on "#notification-action-report" "css_element" in the "Template1" "table_row"
    And I switch to a second window
    And I should see "Nothing to display" in the ".reportbuilder-wrapper" "css_element"
    And I close all opened windows
    And I log out

    And I log in as "student1"
    And I am on "Course 1" course homepage
    And I click on "Mark as done" "button" in the ".section .activity:first-child" "css_element"
    And I click on "Mark as done" "button" in the ".section .activity:nth-child(2)" "css_element"
    And I click on "Mark as done" "button" in the ".section .activity:nth-child(3)" "css_element"
    And I click on "Mark as done" "button" in the ".section .activity:nth-child(4)" "css_element"

    # Completion Status
    # Check the schedule for the instance for No group
    And I click on "#notification-action-report" "css_element" in the "Template1" "table_row"
    And I switch to a second window
    And the following should exist in the "reportbuilder-table" table:
      | Course full name | Message type | Subject                           | Full name      | Time created                    | Scheduled time                  | Status |
      | Course 1         | Template1    | Activity completion notification  | Teacher User 1 | ##now##%A, %d %B %Y, %I:%M %p## | ##now##%A, %d %B %Y, %I:%M %p## | Queued |
    And I close all opened windows

  Scenario: Activity completion condition - passed with activity count
    And I am on "Course 1" course homepage
    And I navigate to "Automation" in current page administration
    And I wait until the page is ready
    And I open the autocomplete suggestions list
    And I click on "Template1" item in the autocomplete list
    And I click on "Add automation instance" "button" in the ".template-add-form" "css_element"
    And I set the field "insreference" to "temp1"
    And I click on "#id_override_frequencylimit" "css_element" in the "#fitem_id_frequencylimit" "css_element"
    And I set the field "frequencylimit" to "1"
    And I press "Save changes"

    # Check the schedule for the instance
    And I click on "#notification-action-report" "css_element" in the "Template1" "table_row"
    And I switch to a second window
    And I should see "Nothing to display" in the ".reportbuilder-wrapper" "css_element"
    And I close all opened windows

    # Instance Conditions - Activity completion
    And I click on ".action-edit" "css_element" in the "Template1" "table_row"
    Then I follow "Condition"
    And I click on "#id_override_triggeroperator" "css_element" in the "#pulse-condition-tab" "css_element"
    Then the field "Trigger operator" matches value "All"
    And I click on "#id_override_condition_activity_status" "css_element" in the "#fitem_id_condition_activity_status" "css_element"
    And I set the field "condition[activity][status]" to "All"
    And I click on "#id_override_condition_activity_modules" "css_element" in the "#fitem_id_condition_activity_modules" "css_element"
    And I set the field "Select activities" in the "#fitem_id_condition_activity_modules" "css_element" to "Assign1, Assign2, Forum1, Forum2, TestPage 01, TestPage 02"
    And I click on "#id_override_condition_activity_acompletionmethod" "css_element" in the "#fitem_id_condition_activity_acompletionmethod" "css_element"
    And I set the field "condition[activity][acompletionmethod]" to "Activity count"
    And I click on "#id_override_condition_activity_activitycount" "css_element" in the "#fitem_id_condition_activity_activitycount" "css_element"
    And I set the field "condition[activity][activitycount]" to "3"
    And I click on "#id_override_condition_activity_completionstatus" "css_element" in the "#fitem_id_condition_activity_completionstatus" "css_element"
    And I set the field "condition[activity][completionstatus]" to "Passed"

    # Instance Notifications
    And I click on "Notification" "link" in the "#automation-tabs" "css_element"
    And I click on "#id_override_pulsenotification_actionstatus" "css_element" in the "#fitem_id_pulsenotification_actionstatus" "css_element"
    And I set the field "id_pulsenotification_actionstatus" to "Enabled"
    And I click on "#id_override_pulsenotification_sender" "css_element" in the "#fitem_id_pulsenotification_sender" "css_element"
    And I set the field "pulsenotification_sender" to "Course teacher"
    And I click on "#id_override_pulsenotification_recipients" "css_element" in the "#fitem_id_pulsenotification_recipients" "css_element"
    And I open the autocomplete suggestions list in the "#fitem_id_pulsenotification_recipients" "css_element"
    And I click on "Teacher" item in the autocomplete list

    And I click on "#id_override_pulsenotification_subject" "css_element" in the "#fitem_id_pulsenotification_subject" "css_element"
    And I set the field "pulsenotification_subject" to "Activity  completion notification"
    And I click on "#id_override_pulsenotification_headercontent_editor" "css_element" in the "#fitem_id_pulsenotification_headercontent_editor" "css_element"
    And I click on "#header-email-vars-button" "css_element" in the ".mod-pulse-emailvars-toggle" "css_element"
    And I click on pulse "id_pulsenotification_headercontent_editor" editor
    And I click on "#Firstname" "css_element" in the ".Sender_field-placeholders" "css_element"
    And I press "Save changes"

    # Check the schedule for the instance for No group
    And I click on "#notification-action-report" "css_element" in the "Template1" "table_row"
    And I switch to a second window
    And I should see "Nothing to display" in the ".reportbuilder-wrapper" "css_element"
    And I close all opened windows
    And I log out

    And I log in as "student1"
    And I am on "Course 1" course homepage
    And I click on "Mark as done" "button" in the ".section .activity:first-child" "css_element"
    And I click on "Mark as done" "button" in the ".section .activity:nth-child(2)" "css_element"
    And I click on "Mark as done" "button" in the ".section .activity:nth-child(3)" "css_element"

    # Completion Status
    # Check the schedule for the instance for No group
    And I click on "#notification-action-report" "css_element" in the "Template1" "table_row"
    And I switch to a second window
    And the following should exist in the "reportbuilder-table" table:
      | Course full name | Message type | Subject                           | Full name      | Time created                    | Scheduled time                  | Status |
      | Course 1         | Template1    | Activity completion notification  | Teacher User 1 | ##now##%A, %d %B %Y, %I:%M %p## | ##now##%A, %d %B %Y, %I:%M %p## | Queued |
    And I close all opened windows

  Scenario: Activity completion condition - partially completed with activity count
    And I am on "Course 1" course homepage
    And I navigate to "Automation" in current page administration
    And I wait until the page is ready
    And I open the autocomplete suggestions list
    And I click on "Template1" item in the autocomplete list
    And I click on "Add automation instance" "button" in the ".template-add-form" "css_element"
    And I set the field "insreference" to "temp1"
    And I click on "#id_override_frequencylimit" "css_element" in the "#fitem_id_frequencylimit" "css_element"
    And I set the field "frequencylimit" to "1"
    And I press "Save changes"

    # Check the schedule for the instance
    And I click on "#notification-action-report" "css_element" in the "Template1" "table_row"
    And I switch to a second window
    And I should see "Nothing to display" in the ".reportbuilder-wrapper" "css_element"
    And I close all opened windows

    # Instance Conditions - Activity completion with Partially completed status
    And I click on ".action-edit" "css_element" in the "Template1" "table_row"
    Then I follow "Condition"
    And I click on "#id_override_triggeroperator" "css_element" in the "#pulse-condition-tab" "css_element"
    Then the field "Trigger operator" matches value "All"
    And I click on "#id_override_condition_activity_status" "css_element" in the "#fitem_id_condition_activity_status" "css_element"
    And I set the field "condition[activity][status]" to "All"
    And I click on "#id_override_condition_activity_modules" "css_element" in the "#fitem_id_condition_activity_modules" "css_element"
    And I set the field "Select activities" in the "#fitem_id_condition_activity_modules" "css_element" to "Assign1, Assign2, Forum1, Forum2, TestPage 01, TestPage 02"
    And I click on "#id_override_condition_activity_acompletionmethod" "css_element" in the "#fitem_id_condition_activity_acompletionmethod" "css_element"
    And I set the field "condition[activity][acompletionmethod]" to "Activity count"
    And I click on "#id_override_condition_activity_activitycount" "css_element" in the "#fitem_id_condition_activity_activitycount" "css_element"
    And I set the field "condition[activity][activitycount]" to "2"
    And I click on "#id_override_condition_activity_completionstatus" "css_element" in the "#fitem_id_condition_activity_completionstatus" "css_element"
    And I set the field "condition[activity][completionstatus]" to "Partially completed"

    # Instance Notifications
    And I click on "Notification" "link" in the "#automation-tabs" "css_element"
    And I click on "#id_override_pulsenotification_actionstatus" "css_element" in the "#fitem_id_pulsenotification_actionstatus" "css_element"
    And I set the field "id_pulsenotification_actionstatus" to "Enabled"
    And I click on "#id_override_pulsenotification_sender" "css_element" in the "#fitem_id_pulsenotification_sender" "css_element"
    And I set the field "pulsenotification_sender" to "Course teacher"
    And I click on "#id_override_pulsenotification_recipients" "css_element" in the "#fitem_id_pulsenotification_recipients" "css_element"
    And I open the autocomplete suggestions list in the "#fitem_id_pulsenotification_recipients" "css_element"
    And I click on "Teacher" item in the autocomplete list

    And I click on "#id_override_pulsenotification_subject" "css_element" in the "#fitem_id_pulsenotification_subject" "css_element"
    And I set the field "pulsenotification_subject" to "Activity partial completion notification"
    And I click on "#id_override_pulsenotification_headercontent_editor" "css_element" in the "#fitem_id_pulsenotification_headercontent_editor" "css_element"
    And I click on "#header-email-vars-button" "css_element" in the ".mod-pulse-emailvars-toggle" "css_element"
    And I click on pulse "id_pulsenotification_headercontent_editor" editor
    And I click on "#Firstname" "css_element" in the ".Sender_field-placeholders" "css_element"
    And I press "Save changes"

    # Check the schedule for the instance - should have nothing before partial completion
    And I click on "#notification-action-report" "css_element" in the "Template1" "table_row"
    And I switch to a second window
    And I should see "Nothing to display" in the ".reportbuilder-wrapper" "css_element"
    And I close all opened windows
    And I log out

    # Student partially completes activities (needs at least 2 with partial completion)
    And I log in as "student1"
    And I am on "Course 1" course homepage
    And I click on "Mark as done" "button" in the ".section .activity:first-child" "css_element"
    And I click on "Mark as done" "button" in the ".section .activity:nth-child(2)" "css_element"

    # Verify notification was triggered for partial completion
    And I click on "#notification-action-report" "css_element" in the "Template1" "table_row"
    And I switch to a second window
    And the following should exist in the "reportbuilder-table" table:
      | Course full name | Message type | Subject                                 | Full name      | Time created                    | Scheduled time                  | Status |
      | Course 1         | Template1    | Activity partial completion notification | Teacher User 1 | ##now##%A, %d %B %Y, %I:%M %p## | ##now##%A, %d %B %Y, %I:%M %p## | Queued |
    And I close all opened windows


