<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

namespace pulseaddon_availability;

/**
 * Tests for recompletion user availabilty records.
 *
 * @package   pulseaddon_availability
 * @copyright 2023, bdecent gmbh bdecent.de
 * @license   http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class recompletion_test extends \mod_pulse\lib_test {
    /**
     * Test local recompletion resets the user availbility in pulse.
     *
     * @covers ::availability_recompletion_reset
     * @return void
     */
    public function test_availability_recompletion_reset(): void {
        global $DB;

        $students[] = $this->getDataGenerator()->create_and_enrol($this->course, 'student', [
            'email' => 'student1@test.com',
            'username' => 'student1',
        ]);

        $students[] = $this->getDataGenerator()->create_and_enrol($this->course, 'student', [
            'email' => 'student2@test.com',
            'username' => 'student2',
        ]);

        $course2 = $this->getDataGenerator()->create_course();
        $this->getDataGenerator()->create_module('pulse', [
            'course' => $course2->id, 'intro' => $this->intro,
        ], []);

        $this->getDataGenerator()->enrol_user($students[0]->id, $course2->id);
        $this->getDataGenerator()->enrol_user($students[1]->id, $course2->id);

        // Update availability.
        // Get the list of availabletime scheduled tasks and execute them.
        $availabletime = \core\task\manager::get_scheduled_task('\\pulseaddon_availability\\task\\availabletime');
        if ($availabletime) {
            $availabletime->execute();
            $availability = \core\task\manager::get_adhoc_tasks('\\pulseaddon_availability\\task\\availability');
            if ($availability) {
                foreach ($availability as $task) {
                    $task->execute();
                }
            }
        }

        // Send notification.
        $this->send_message();
        $result = \mod_pulse\helper::pulseis_notified($students[0]->id, $this->module->id);
        $this->assertTrue($result);

        // Confirm the user enrolment in the course 1.
        $selectsql = 'userid IN (:userid1, :userid2) AND pulseid IN (SELECT id FROM {pulse} WHERE course = :courseid)';
        $params = ['userid1' => $students[0]->id, 'userid2' => $students[1]->id, 'courseid' => $this->course->id];
        $records = $DB->get_records_select('pulseaddon_availability', $selectsql, $params);
        $this->assertCount(2, $records);

        // Verify the user availability in all course.
        $selectsql = 'userid IN (:userid1, :userid2)';
        $params = ['userid1' => $students[0]->id, 'userid2' => $students[1]->id];
        $records = $DB->get_records_select('pulseaddon_availability', $selectsql, $params);
        $this->assertCount(4, $records);

        // Reset the completion.
        $config = new \stdClass();
        $config->pulse = LOCAL_RECOMPLETION_DELETE;
        foreach ($students as $student) {
            \mod_pulse\helper::local_recompletion_reset($student->id, $this->course, $config);
        }

        // Confirm the user enrolment in the course 1.
        $selectsql = 'userid IN (:userid1, :userid2) AND pulseid IN (SELECT id FROM {pulse} WHERE course = :courseid)';
        $params = ['userid1' => $students[0]->id, 'userid2' => $students[1]->id, 'courseid' => $this->course->id];
        $records = $DB->get_records_select('pulseaddon_availability', $selectsql, $params);
        $this->assertCount(0, $records);

        // Verify the user availability in all course.
        $selectsql = 'userid IN (:userid1, :userid2)';
        $params = ['userid1' => $students[0]->id, 'userid2' => $students[1]->id];
        $records = $DB->get_records_select('pulseaddon_availability', $selectsql, $params);
        $this->assertCount(2, $records);
    }
}
