require 'twilio-ruby'
require 'logger'
#require 'airbrake'
class TestEventsController < ApplicationController
  include ApplicationHelper
  # GET /event_processes
  # GET /event_processes.json
  #$env =  "dev"# (Rails.env.production?)? "prod" : "dev"

  helper_method :process_test_event_queue
  def new

  end
  def process_test_event_queue()

    sqsName =  "event"
    #
    #
    users_queue = AwsSqs.create_sqs(sqsName)
    ##AwsSqs.push_test_message(sqsName,message.to_json)
    users_queue.poll(:initial_timeout => false,
                     :wait_time_seconds => 10){|msg| new_event_process(msg)}

  end

  def new_event_process(queue_msg)
    if (!queue_msg.nil?)

      msg_body = JSON.parse(queue_msg.body)
      puts queue_msg
      #puts queue_msg["message"]
      puts msg_body
      puts msg_body["message"]
      if (!msg_body["message"].nil?  )
        process_new_event(msg_body["message"])
      end
    end

  end

  def  process_new_event(event_message)

    if (event_message.has_key?("action") )

      action = event_message["action"]

      case action
        when "new_event"
          new_event(event_message)

        when "book_plan"
          book_plan(event_message)

        when "cancel_event"
          cancel_event(event_message)

        when "new_attendees"
          new_attendees(event_message)
        when "change_event"
          change_event(event_message)

        when "new_plan"
          new_plan(event_message)

        when "chat_messages"
          chat_messages(event_message)

        when "event_plan_response"
          event_plan_response(event_message)

        when "edit_plan"
          edit_plan(event_message)


        when "nudge"
          nudge(event_message)
      end
    end
  end


  def  new_event(event_message)
    puts "IN NEW EVENT"


    user_record =   verify_user_on_users_table(event_message["phone_number"])


    raise "Invalid user record message #{event_message}" unless (!user_record.nil? && !user_record.empty?)

    user = AwsUser.set_user(user_record)
    #puts "USER #{user.first_name}"
    raise "Organizer #{event_message["phone_number"]} wasn't found on users table" unless (!user.nil? && user.valid_user)
    event = AwsEvent.new_event_record_from_hash_message(event_message,user)

    raise "Invalid event #{event_message}" unless (event.is_valid_event)
    #### save to Event table
    event.save_event_record_to_db
    #### save to EventPlan table
    AwsEventPlan.save_event_plans(event.event_plans)
    #AwsEventPlan.generate_and_save_event_plans_records(event.event_plans,event,user)
    #### save to EventPlanUser table

    AwsEventPlanUser.save_event_plan_users(AwsEventPlanUser.setup_event_plan_user_from_event(event))
    #### save to UsersEvent table

    AwsUsersEvents.save_users_events_from_users_phones(event.attendees_phones,event.id)
    ## Notify atendees (SNS/SMS)
    process_new_event_attendees_message(event,user)

    AwsNonUsers.process_non_users(event.attendees,user)

  end
  def process_new_event_attendees_message(event,inviter)

    aws_invitees_device_tokens = AwsUsersDeviceTokens.get_users_device_tokens_from_aws(event.attendees_phones)

    alert =TextMessages.get_new_event_invitation_push(inviter.first_name,inviter.last_name,event.title)

    hidden_message = EventPushNotificationMessage.new_event(event.id,event.title)

    non_users_message = TextMessages.get_invitation_to_non_user_sms(inviter.first_name,inviter.last_name)#  invited you to meet. Download Clowder to get together: http://bit.ly/calaborate"

    alert_event_attendees(aws_invitees_device_tokens,hidden_message,alert,non_users_message,[inviter.phone_number])

  end


  def edit_plan(event_message)
    consistent_read = event_message.has_key? ("resent_count")
    user = AwsUser.verify_user_on_users_table(event_message["phone_number"])
    if (!user.nil? && user.valid_user )
    event = AwsEvent.set_event_record_from_db(event_message["event_id"],consistent_read)
    old_event_plan_id = (event_message.has_key?("event_plan_id"))? event_message["event_plan_id"]  :""
    new_event_plan_message =  (event_message.has_key?("event_plan"))? event_message["event_plan"]  :""
    if (event.is_valid_event && !old_event_plan_id.empty? && event.events_plans_ids.include?(old_event_plan_id) && !new_event_plan_message.empty?)
      old_event_plan = AwsEventPlan.get_event_plan_from_db(event, old_event_plan_id)
      new_event_plan = AwsEventPlan.get_event_plan_objects_from_message(new_event_plan_message,event,user)
      if(!new_event_plan.nil? && new_event_plan.is_valid_plan && !old_event_plan.nil? && old_event_plan.is_valid_plan && old_event_plan.event_plan_organizer_phone==user.phone_number)
        event.add_plans([new_event_plan])
        AwsEventPlan.save_event_plans([new_event_plan])
        AwsEventPlanUser.save_event_plan_user_from_plans_for_current_event_users(event,[new_event_plan])
        AwsEventPlan.update_event_plan_edit(event.id, new_event_plan.id,old_event_plan.id)
        notify_edit_event_plan(event,user,new_event_plan)
      end
    end

    end
    end
  def notify_edit_event_plan(event,user,new_event_plan)

    aws_users_device_tokens = AwsUsersDeviceTokens.get_users_device_tokens_from_aws(event.attendees_phones)

    alert = TextMessages.get_edit_plan_push(user.first_name,event.title)


    hidden_message = EventPushNotificationMessage.edit_plan(event.id,new_event_plan.id)

    alert_event_attendees(aws_users_device_tokens,hidden_message,alert,[])

  end

  def new_plan(event_message)
    #AwsS3.new

    puts "IN NEW PLAN"
    consistent_read = event_message.has_key? ("resent_count")

    event = AwsEvent.set_event_record_from_db(event_message["event_id"],consistent_read)

    if (event.is_valid_event)
      user = AwsUser.verify_user_on_users_table(event_message["phone_number"])
      raise "Organizer #{event_message["phone_number"]} wasn't found on users table" unless (!user.nil? && user.valid_user && event.attendees_phones.include?(user.phone_number))
        event_plans =  event_message["event_plans"]
        new_event_plan_objects = Array.new

        event_plans.each do |event_plan|
          new_event_plan_object = AwsEventPlan.get_event_plan_objects_from_message(event_plan,event,user)
          new_event_plan_objects.push(new_event_plan_object)
        end

          ## Saves new plans to Event table
          event.add_plans(new_event_plan_objects)
          ## Save new plan to EventPlan table
          AwsEventPlan.save_event_plans(new_event_plan_objects)
          ## Save to EventPlanUser
          AwsEventPlanUser.save_event_plan_user_from_plans_for_current_event_users(event,new_event_plan_objects)
          process_new_event_plan(event,new_event_plan_objects,user)

    else
      puts "NO EVENT FOUND"
      resend_message_to_event_queue(event_message,3,event_message['action'],"NO EVENT FOUND")
    end

  end
  def process_new_event_plan(event,event_plan,user)
    aws_users_device_tokens  = AwsUsersDeviceTokens.get_users_device_tokens_from_aws(event.attendees_phones)
    alert = TextMessages.get_new_plan_push(user.first_name, event.title)

    puts "ALERT #{alert}"
    hidden_message = EventPushNotificationMessage.new_plan(event.id,event.events_plans_ids)

    alert_event_attendees(aws_users_device_tokens,hidden_message,alert,[])#send_event_push_notification(phone_numbers_push_endpoints,hidden_message,alert)

  end

  def book_plan(event_message)

    puts "IN BOOK EVENT"
    event = AwsEvent.set_event_record_from_db(event_message["event_id"])
    user =  AwsUser.verify_user_on_users_table(event_message["phone_number"])

    raise "User number #{event_message["phone_number"]} wasn't found on users table " unless (user.valid_user)

    event.set_booked_plan_id(event_message["event_plan_id"])


    raise "Event Invalid for booking #{event_message}" unless (event.is_valid_for_book(user.phone_number))


    booked_plan = AwsEventPlan.get_event_plan_from_db(event, event.event_plan_id)
    raise "Event plan wasnt found " unless (booked_plan.is_valid_plan)

      raise "Only Event Organizer can book a plan #{event_message} " unless (booked_plan.event_organizer_phone == event.phone_number)
        if (!event.attendees_phones.empty?)
          event.update_booked_event
          #AwsEventPlanUser.update_event_plan_user(event.phone_number,event.event_plan_id,"yes")
          organizer_vote_yes = AwsEventPlanUser.get_user_vote(event.phone_number,event.event_plan_id)== 'yes'
          #if (AwsEventPlanUser.get_user_vote(event.phone_number,event.event_plan_id)== 'yes')
            notify_booked_event_attendees(event,booked_plan,organizer_vote_yes)
          #end
        end

  end
  def notify_booked_event_attendees(event,booked_plan,organizer_vote_yes)


    aws_users_device_tokens = AwsUsersDeviceTokens.get_users_device_tokens_from_aws(event.attendees_phones)
    #Good news everyone! You’re booked for “#{event_title}”! Feel free to keep chatting until the event starts.
    alert = (organizer_vote_yes)? TextMessages.get_booked_event_push(booked_plan.title):''#"Good news everyone! You are booked for '#{plan_record["title"]}'! Feel free to keep chatting until the event starts."

    hidden_message = EventPushNotificationMessage.book_plan(booked_plan.event_id,booked_plan.id)

    alert_event_attendees(aws_users_device_tokens,hidden_message,alert,alert,[])

  end
  def cancel_event(event_message)

    puts "IN CANCEL EVENT"
    event = AwsEvent.set_event_record_from_db(event_message["event_id"])


    raise "Invalid event #{event_message}" unless (event.is_valid_event)

    user = AwsUser.verify_user_on_users_table(event_message["phone_number"])

    raise "User number #{event_message["phone_number"]} wasn't found on users table" unless (!user.nil? && user.valid_user )


    raise "Event wasnt found or ,ONLY EVENT ORGANIZER CAN CANCEL THE EVENT... #{event_message}" unless (event.phone_number == event_message["phone_number"])

    event.update_canceled_event

    AwsEventPlanUser.update_event_plan_user(event.phone_number,event.event_plan_id,"no")


    notify_cancel_event_attendees(event,user)

  end
  def notify_cancel_event_attendees(event,user)

    #Sorry, [Firstname ] cancelled “[EVENT NAME]”!
    aws_invitees_device_tokens = AwsUsersDeviceTokens.get_users_device_tokens_from_aws(event.attendees_phones)
    alert = TextMessages.get_cancelled_event_push(user.first_name, event.title)
    hidden_message = EventPushNotificationMessage.cancel_event(event.id,event.title)

    alert_event_attendees(aws_invitees_device_tokens,hidden_message,alert,"",[])

  end

  def  chat_messages(event_message)
    consistent_read = event_message.has_key? ("resent_count")
    event = AwsEvent.set_event_record_from_db(event_message["event_id"],consistent_read)
    messages = (event_message.has_key?("messages"))? event_message["messages"] :Array.new

    if (event.is_valid_event && !messages.nil? && !messages.empty?)

      user =  AwsUser.verify_user_on_users_table(event_message["phone_number"])
      raise "User number #{event_message["phone_number"]} wasn't found on users table" unless (user.valid_user && event.in_event(user))
        aws_messages = AwsMessage.save_valid_messages_from_protocol(messages,event,user)
        if (!aws_messages.nil? && !aws_messages.empty?)
          notify_new_event_messages(event,aws_messages,user)
        end

    else
      resend_message_to_event_queue(event_message,3,event_message['action'],"NO EVENT FOUND")
    end
  end
  def change_event(event_message)

    puts "IN CHANGE EVENT"
    event = AwsEvent.set_event_record_from_db(event_message["event_id"])


    raise "Invalid event #{event_message}" unless (event.is_valid_event)
    user = AwsUser.verify_user_on_users_table(event_message["phone_number"])
    raise "EVENT EITHER DONT exists OR THE EVENT TITLE EDITOR ISN'T THE ORGANIZER #{event_message}" unless (!user.nil? && user.valid_user && user.phone_number==event.phone_number)
    new_title = event_message["title"]
    old_title = event.title
    ## Save to Event table
    event.change_event_title(new_title)
    notify_change_event(event,user,old_title)


  end
  def notify_change_event(event,user,old_title)#phone_number,new_title,event_record,change_event_user_phone_number,inviter_record)


    alert = TextMessages.get_edit_plan_push(user.first_name, old_title)

    hidden_message = EventPushNotificationMessage.change_event(event.id)

    aws_users_device_tokens = AwsUsersDeviceTokens.get_users_device_tokens_from_aws(event.attendees_phones)


    alert_event_attendees(aws_users_device_tokens,hidden_message,alert,"")
  end
  def event_plan_response(event_message)

    consistent_read = event_message.has_key? ("resent_count")
    event = AwsEvent.set_event_record_from_db(event_message["event_id"],consistent_read)
    status = (event_message.has_key?("status"))? event_message["status"] : ""
    user_phone =  (event_message.has_key?("phone_number"))? event_message["phone_number"]:""
    event_plan_id = (event_message.has_key?("event_plan_id"))? event_message["event_plan_id"] :""
    if (event.is_valid_event && !status.empty? && !user_phone.empty? && !event_plan_id.empty? && event.events_plans_ids.include?(event_plan_id))
      user = AwsUser.verify_user_on_users_table(user_phone)
      raise "User number #{event_message["phone_number"]} wasn't found on users table" unless (!user.nil? && user.valid_user)

        AwsEventPlanUser.update_event_plan_user(user_phone,event_plan_id,status)

        ## stop sending text push notification on event votes
        aws_users_device_tokens = AwsUsersDeviceTokens.get_users_device_tokens_from_aws(event.attendees_phones)
        alert = ""# (event_record.has_key?("title") && !event_record["title"].empty?)? "New update on #{event_record["title"]}": ""
        hidden_message = EventPushNotificationMessage.event_plan_response(event.id,event_plan_id,status)
        #none =  'none'
        #puts "NO SOUND ALERT #{none}"

        alert_event_attendees(aws_users_device_tokens,hidden_message,'','',[user.phone_number],'none')

    else
      resend_message_to_event_queue(event_message,3,event_message['action'],"NO EVENT FOUND")

    end

  end


  def  notify_new_event_messages(event,messages,user)
      aws_users_device_tokens = AwsUsersDeviceTokens.get_users_device_tokens_from_aws(event.attendees_phones)
      alert = TextMessages.get_chat_message_push(user.first_name, messages[0].content)

      hidden_message = EventPushNotificationMessage.chat_messages(event.id)

      alert_event_attendees(aws_users_device_tokens,hidden_message,alert,"",[user.phone_number])

  end



  def new_attendees(event_message)
    puts "IN NEW ATTENDEE EVENT"

    event = AwsEvent.set_event_record_from_db(event_message["event_id"])
    raise "Invalid event #{event_message}" unless (event.is_valid_event)
    current_attendees = event.attendees_phones.clone
    user = AwsUser.verify_user_on_users_table(event_message["phone_number"])

    raise "Organizer #{event_message["phone_number"]} wasn't found on users table" unless (user.valid_user)
    new_attendees_messages = event_message["new_attendees"]
    new_users_attendees_objects = Array.new
    new_users_attendees_phones = Array.new
    new_attendees_messages.each do |attendee_message|
    new_attendee = AwsUser.set_user(attendee_message)

      if (new_attendee.valid_attendee)
        new_users_attendees_objects.push(new_attendee)
        new_users_attendees_phones.push(new_attendee.phone_number)

      end

    end


   if (!new_users_attendees_objects.empty?)
     ## Save to Event table new attendees
     event.add_attendees(new_users_attendees_objects)

     event.set_event_plans_from_ids
      ##   Generate and Save records to EventPlanUser table
     AwsEventPlanUser.save_event_plan_user_from_plans_for_event_users(new_users_attendees_objects,event.event_plans)
     ## Save to UsersEvents table
     AwsUsersEvents.save_users_events_from_users_phones(new_users_attendees_phones,event.id)
     notify_event_new_attendees(event,current_attendees,user)

     AwsNonUsers.process_non_users(new_users_attendees_objects,user)
   end

   end
  def notify_event_new_attendees(event,current_attendees_phones,user_inviter)

    new_attendees_clowder_users =  event.attendees_phones.clone
    new_attendees_clowder_users = new_attendees_clowder_users - current_attendees_phones
    new_attendees_clowder_users.push(user_inviter.phone_number)
    aws_invitees_devices_tokens = AwsUsersDeviceTokens.get_users_device_tokens_from_aws(event.attendees_phones)
    alert =TextMessages.get_new_attendees_push(event.title) #(event_record.has_key?("title") && !event_record["title"].empty? )?"New Attendees were added to  #{event_record["title"]} ":""


    hidden_message = EventPushNotificationMessage.new_attendees(event.id)
    alert_event_attendees(aws_invitees_devices_tokens,hidden_message,alert,"",new_attendees_clowder_users)


    alert =TextMessages.get_new_event_invitation_push(user_inviter.first_name,user_inviter.last_name,event.title)

    hidden_message = EventPushNotificationMessage.new_event(event.id,event.title)

    non_users_message = TextMessages.get_invitation_to_non_user_sms(user_inviter.first_name, user_inviter.last_name)#  invited you to meet. Download Clowder to get together: http://bit.ly/calaborate"
    old_attendees =  event.attendees_phones.clone -  new_attendees_clowder_users
    old_attendees.push(user_inviter.phone_number)
    return alert_event_attendees(aws_invitees_devices_tokens,hidden_message,alert,non_users_message,old_attendees)


  end

  def nudge(event_message)

    raise "Inavlid message #{event_message}" unless (event_message.has_key?("event_id") && !event_message["event_id"].empty? && event_message.has_key?("phone_number") && !event_message["phone_number"].empty? && event_message.has_key?("nudge_numbers") && !event_message["nudge_numbers"].empty?)

    user = AwsUser.verify_user_on_users_table(event_message["phone_number"])

    raise "Invalid User #{event_message["phone_number"]}" unless (user.valid_user)
    event = AwsEvent.set_event_record_from_db(event_message["event_id"])
    raise "Invalid Event #{event_message}" unless (!event.nil? && event.is_valid_event)
    nudge_numbers =  event_message["nudge_numbers"]
    aws_invitees_device_tokens = AwsUsersDeviceTokens.get_users_device_tokens_from_aws(nudge_numbers)
    alert =TextMessages.get_nudge_notification(user.first_name,event.title)
    hidden_message = EventPushNotificationMessage.nudge(event.id,user.phone_number)
    alert_event_attendees(aws_invitees_device_tokens,hidden_message,alert,"",[user.phone_number])

  end


  def alert_event_attendees(aws_invitees_device_tokens,hidden_message,alert,non_users_message,dont_alert_phones=[],alert_sound=nil)

    dont_alert_phones = (!dont_alert_phones.nil?) ? dont_alert_phones : Array.new
    puts "DONT ALERT #{dont_alert_phones} ALERT non== #{non_users_message}"
    if (!aws_invitees_device_tokens.nil? && !aws_invitees_device_tokens.empty?)
      phone_numbers_push_endpoints = Array.new
      non_users = Array.new
      non_users_objects = Array.new

      aws_invitees_device_tokens.each do |invitee|

        if (invitee.valid_user_device_token && !dont_alert_phones.include?(invitee.phone_number))
            phone_numbers_push_endpoints.push(invitee.device_token_arn)
        else
          if (invitee.non_user && !dont_alert_phones.include?(invitee.phone_number))

             non_users.push(invitee.phone_number)
             non_users_objects.push(invitee)
          end
        end
      end
      if (!phone_numbers_push_endpoints.nil? && !phone_numbers_push_endpoints.empty?)

        send_event_push_notification(phone_numbers_push_endpoints,hidden_message,alert,alert_sound)
      end
      if (!non_users.nil? && !non_users.empty?)
        puts "ALERT NON #{non_users} ALERT non== #{non_users_message}"

        process_non_users_phones(non_users,non_users_message)
      end
    end

    return non_users_objects
  end
  def send_event_push_notification(phone_numbers_push_endpoints,hidden_message,alert,alert_sound)


    if (!hidden_message.nil?  && !alert.nil?)
      phone_numbers_push_endpoints.each do|endpoint|
        puts "SEND USERS PUSH #{endpoint}"
        puts "MESSAGE #{hidden_message}"
        AwsSns.send_push_notification(endpoint,hidden_message,alert,alert_sound)
      end
    end


  end

  # save all non users records to the non_user table and send SMS invite
  def process_non_users(non_users,message)
    puts "NON USER IS = #{non_users}"
    #message = "New Clowder event - you've been invited to #{event_record["title"]}"
    if (!non_users.nil? && !non_users.empty?)

      AwsUser.save_non_users(non_users)
      TwillioSms.new
      non_users.each do |non_user|
        TwillioSms.send_sms(non_user.phone_number,message)
      end
    end
  end

  def process_non_users_phones(non_users,message)
    puts "NON USER IS = #{non_users}"
    if (!non_users.nil? && !non_users.empty?)
      TwillioSms.new

      non_users.each do |non_user|
        TwillioSms.send_sms(non_user,message)
      end
    end
  end
  def remove_empty_attributes(record)
    new_record = Hash.new

    if (!record.nil? && !record.empty?)
      record.each {|key,value|

        if ((value.nil? || (!value.nil? && value.is_a?(String) && value.empty?)) )
          record.delete(key)

        end
      }

      new_record = record
    end

    return new_record
  end
  def remove_empty_key_attribute_from_array_hash(hash_key_value_records_array,attribute_key_to_delete)
    new_records = Array.new


    if (!hash_key_value_records_array.nil? && !hash_key_value_records_array.empty?)
      hash_key_value_records_array.each do |record|
        new_record =  remove_empty_attributes(record)


        if (!new_record.nil? && !new_record.empty?)
          if (new_record.has_key?(attribute_key_to_delete) )
            new_record.delete(attribute_key_to_delete)
          end
          new_records.push(new_record)
        end

      end

    end

    return new_records
  end
  def verify_user_on_users_table(phone_number)
    user_record = {}
    puts "PHPNE #{phone_number}"
    if (!phone_number.nil? && !phone_number.empty?)
      #AwsDevDynamodb.new
      current_user_record = AwsDynamodb.get_record_from_table_name_by_hash_key_value("users",phone_number,[:phone_number, :string])
      user_record =   (!current_user_record.nil? && !current_user_record.empty?)? current_user_record : user_record
    end
    return user_record
  end

  def resend_message_to_event_queue(message_to_queue, send_limlit_number, s3_action, s3_message)
    unless Rails.env.test?
    if (!message_to_queue["event_id"].nil? && !s3_action.nil? && !s3_message.nil?)
    sqsName =  'event'
    users_queue = AwsSqs.create_sqs(sqsName)
    message_to_queue["resent_count"] = (message_to_queue.has_key? ("resent_count"))? message_to_queue["resent_count"]+1 : 1
    raise "Couldnt find event  after 3 consequence search  #{message_to_queue}" unless (send_limlit_number > message_to_queue["resent_count"])
      message  = {:message => message_to_queue   }
      if (!message.nil? && !message.empty?)
        puts "RESEND TO EVENT QUEUE #{message} count sent #{message_to_queue["resent_count"]}"
        AwsSqs.push_message(sqsName,message.to_json,60)
      end

    end
    end
    end
end