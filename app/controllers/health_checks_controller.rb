class HealthChecksController < ApplicationController
  # GET /health_checks
  # GET /health_checks.json
  @approximate_number_of_messages=3
  helper_method :health_check_sqs
  def health_check_sqs
    health_checked = AwsSqs.health_check('event',3)
    puts "HEALTH CHECK FOR event QUEUE  is === #{health_checked}"
    if health_checked
      head 200
      puts "HEAD 200"
    else

      head 200
      puts "HEAD 500 Try restating the test_events_controller for polling messages"
      testEventsController = TestEventsController.new
      testEventsController.process_test_event_queue


    end
  end
end