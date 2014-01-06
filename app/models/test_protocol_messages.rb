class TestProtocolMessages
  #event = AwsEvent.new
  #event.internal_new_from_message(JSON.parse(message))
  # event_plan = AwsEventPlan.new
  #event_plan.internal_new_from_message(JSON.parse(event_plan_message),event)
  #event.set_attendees_phones(['+13109271510','3102275317','+13102275317'])
  #AwsEventPlanUser.save_event_plan_user_from_plans_for_current_event_users(event,[event_plan])
  #
  ##puts "SHOULD BE YES == #{AwsEventPlanUser.get_user_vote('+12134078526','4E4BEE4E-8C1A-497D-80DE-682F897A92A0') }"
  #puts "SHOULD BE PENDING == #{AwsEventPlanUser.get_user_vote('+12133930635','F1A3B2BB-9BDA-4A01-BD80-49FC9A55DECF') }"
  #puts "SHOULD BE NO == #{AwsEventPlanUser.get_user_vote('+12134078526','BF7F66D0-8325-40C7-8990-16B89BD30DEB') }"
  #puts "SHOULD BE NOTHING ,NO USER == #{AwsEventPlanUser.get_user_vote('+1111111','BF7F66D0-8325-40C7-8990-16B89BD30DEB') }"
  #puts "SHOULD BE NOTHING, NO EVENT PLAN == #{AwsEventPlanUser.get_user_vote('+12134078526','BF7F66D0') }"

  #AwsSns.send_all
  #AwsSns.enable_user_push_notification('da8941ef8acc0fa8fccd37322d8fab5bfb728f1e3b4a56e3041b6db410fa80a9','3106334729')
  #AwsSns.send_push_notification('arn:aws:sns:us-west-2:336183161136:endpoint/APNS/CalEnterprise/629fd93c-85ae-3a81-a79a-21f53db1ad00','',"Hello Enable!",nil)#('arn:aws:sns:us-west-2:336183161136:endpoint/APNS/CalEnterprise/9b05ca50-1b33-32b0-a76d-ba7b0a143b1d')
  message =
      {:message => { :user_id =>'9F1DBE48-71D7-407E-9E5D-71267D4256B5',
                     :phone_number =>  '+13102275317',
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

      } }
  message =  {:message => {:action => "new_plan",
                           :event_plans =>[{:location_title =>"CHICAGO",
                                            :dtstart =>"2013-11-06T17:40:00+00:00",
                                            :created_at =>"2013-11-06T17:20:09+00:00",
                                            :latitude =>34.018717,
                                            :location =>"820 Broadway, CHICAGO, United States",
                                            :longitude =>-118.488941,
                                            :duration =>0,
                                            :event_plan_id =>"TEST-EVENT-PLAN-8"}],
                           :user_id =>'9F1DBE48-71D7-407E-9E5D-71267D4256B5',
                           :phone_number =>  '+13109271510',
                           :event_id=>'TEST-EVENT-ID-2',}}
  #message = {:message =>{:new_attendees =>[{:phone_number =>"+13109271510",
  #                                          :first_name =>"Lasha",
  #                                          :last_name =>"E"}],
  #                       :action =>"new_attendees",
  #                       :user_id =>'9F1DBE48-71D7-407E-9E5D-71267D4256B5',
  #                       :phone_number =>  '+13102275317',
  #                       :event_id=>'TEST-EVENT-ID-2'}}
  message =
      {:message => {:user_id =>'9F1DBE48-71D7-407E-9E5D-71267D4256B5',
                    :phone_number =>  '+13102275317',
                    :event_id=>'TEST-EVENT-ID-2',
                    :action => 'change_event' ,

                    :title => 'Six Flags - TEST!!'

      } }
  message =
      {:message => {
          :user_id =>'9F1DBE48-71D7-407E-9E5D-71267D4256B5',
          :phone_number =>  '+13109271510',
          :event_id=>'TEST-EVENT-ID-2',
          :action => 'edit_plan' ,
          :event_plan_id =>'TEST-EVENT-PLAN-8',
          :event_plan=>
              {
                  :location =>'Max Brenner',
                  :longitude =>1378941198.937706,
                  :latitude=>1378941198.937706,
                  :event_plan_id => 'TEST-EVENT-PLAN-9',
                  :dtstart =>'2013-11-14T17:55:06+07:00',
                  :created_at=>'2013-10-14T17:55:06+07:00',
                  :location_title=>'Max Brenner',
                  :title => 'Max Brenner title',
                  :duration=>7
              }

      } }
  message = {:message => {:action => "event_plan_response",
                          :user_id =>'9F1DBE48-71D7-407E-9E5D-71267D4256B5',
                          :phone_number =>  '+13102275317',
                          :event_id=>'TEST-EVENT-ID-2',
                          :event_plan_id =>"TEST-EVENT-PLAN-9",
                          :status =>"yes"
  }}
  message =
      {:message => {		:user_id =>'9F1DBE48-71D7-407E-9E5D-71267D4256B5',
                        :phone_number =>  '+13102275317',
                        :event_id=>'TEST-EVENT-ID-2',
                        :action => 'cancel_event' ,




      } }
  message =
      {:message => {		:user_id =>'9F1DBE48-71D7-407E-9E5D-71267D4256B5',
                        :phone_number => '+13102275317',
                        :event_id=>'TEST-EVENT-ID-2',
                        :action => 'book_plan' ,
                        :event_plan_id => 'TEST-EVENT-PLAN-9',



      } }
  message =
      {:message => {		:user_id =>'9F1DBE48-71D7-407E-9E5D-71267D4256B5',
                        :phone_number => '+13109271510',
                        :event_id=>'TEST-EVENT-ID-2',
                        :action => 'chat_messages' ,

                        :messages => [   	{   	:content => 'TRADER JOES ?...',
                                               :created_at => '2013-10-14T17:55:06+07:00',
                                               :message_id => 'TEST-MESSAGE-1'

                                          },
                                          {
                                              :content => 'WHOLE FOODS?',
                                              :created_at => '2013-10-14T17:55:06+07:00',
                                              :message_id => 'TEST-MESSAGE-2'
                                          }

                        ]


      } }
  #AwsSqs.push_test_message( "test_event_#{$env}","TESTING PRODUCTION -  dev_event table exists = #{AwsDynamodb.get_table_by_name('event').exists?}")


  #puts "ACCESS KEY #{ENV["AWS_ACCESS_KEY_ID"]} ===  AWS_SECRET_KEY -   #{ENV["AWS_SECRET_KEY"]}"

  #AwsSqs.push_test_message( "test_event_#{$env}","ACCESS KEY #{ENV["AWS_ACCESS_KEY_ID"]} ===  AWS_SECRET_KEY -   #{ENV["AWS_SECRET_KEY"]}")

  puts "SHARON TESTING TESTING...."
end