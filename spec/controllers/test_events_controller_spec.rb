require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe TestEventsController do

  describe "process invalid messages" do

    it "handles an empty body" do
      empty_message = JSON.parse({}.to_json)
      controller.process_new_event(empty_message)
      # If it doesn't crash, it is successful -- we can do nothing with a log of an empty body
    end

    it "handles a json container with no action" do
      bogus_message = JSON.parse({"bogus" => "foo"}.to_json)
      controller.process_new_event(bogus_message)
    end

    it "handles a bogus action" do
      bogus_action = JSON.parse({"action" => "bogus" }.to_json)
      controller.process_new_event(bogus_action)
    end

  end

  describe "new event" do
    it "creates new event with plan and non user " do
  message = { :user_id =>'9F1DBE48-71D7-407E-9E5D-71267D4256B5',
                     :phone_number =>  '+1111',
                     :event_id=>'TEST-EVENT-ID-2',
                     :action => 'new_event' ,
                     :status => 'pending',
                     :title => 'Thanksgiving TEST 2',
                     :created_at => '2013-11-30T13:04:15+00:00',
                     :event_plans=> [
                         {:location_title =>"START Fitness",
                          :dtstart =>"2013-10-26T14:00:00+00:00",
                          :created_at =>"2013-10-22T13:04:55+00:00",
                          :latitude =>37.78812, :location =>"1625 Bush Street, San Francisco, CA, United States",
                          :longitude =>-122.424092,
                          :duration =>0,
                          :event_plan_id =>"TEST-EVENT-PLAN-2"}],
                     :attendees => [{    :first_name => 'Sharona',
                                         :last_name => 'Non User',
                                         :phone_number => '3102275317'

                                    } ]

      }.to_json
  msg_body = JSON.parse(message)
      #event_message = JSON.parse(message)
      #expect(AwsS3).to receive(:log_to_bucket) { double("logger") }
      controller.new_event(msg_body)
    end
    #it "logs an error if there's no event_id" do
    #  no_event_id_message = JSON.parse({"action" => "new_event", "phone_number" => "5555551212"}.to_json)
    #  #expect(AwsS3).to receive(:log_to_bucket) { double("logger") }
    #  controller.new_event(no_event_id_message)
    #end
  end

  describe "new plan" do
    #before :each do
    #  @basic_message = {
    #      "action" => "new_plan",
    #      "phone_number" => TestData.vega_phone_number,
    #      "event_id" => TestData.dinner_id,
    #      "user_id" => "XYZ",
    #      "event_plans" => [{"id" => "EFGH", "event_plan_id" => "EFGH", "event1" => "foo", "created_at" => "2013-10-14T17:55:06+07:00",
    #                         "dtstart" => "2013-10-14T17:55:06+07:00"}]
    #  }
    #end

    #it "logs an error if there's no event with the event_id" do
    #  msg = @basic_message.clone
    #  msg["event_id"] = "bogus"
    #  no_event_message = JSON.parse(msg.to_json)
    #  expect(controller).to receive(:resend_message_to_event_queue) { double("logger") }
    #  controller.new_plan(no_event_message)
    #end
    #
    #it "works if the event exists" do
    #  expect(AwsDynamodb).to receive(:save_record) { double("awsdevdynamodb")}
    #  expect(AwsDynamodb).to receive(:save_all_records) { double("awsdevdynamodb2")}
    #  controller.new_plan(JSON.parse(@basic_message.to_json))
    #end
    #
    #it "raises an error if dtstart is missing in a plan" do
    #  msg = @basic_message.clone
    #  msg["event_plans"][0].delete("dtstart")
    #  msg["event_plans"][0]["id"] = "IJKL"
    #  expect{controller.new_plan(JSON.parse(msg.to_json))}.to raise_error(ArgumentError)
    #
    #end

  end

end
