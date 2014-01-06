class AwsEvent

  @id
  @attendees
  @attendees_phones
  @created_at
  @event_attendees_push_end_points
  @event_plan_id
  @event_plans
  @events_plans_ids
  @phone_number
  @status
  @title
  @update_at
  @user_id
  #@event_plans

  def new

  end

  def set_attendees_phones(attendees_phones)
    @attendees_phones = attendees_phones
  end
  def id
    return (@id.nil?)? "" : @id

  end

  def event_plans
    return (@event_plans.nil?)? Array.new : @event_plans
  end

  def add_plan(event_plan)
    if (@event_plans.nil? || @event_plans.empty?)
      @event_plans = Array.new
    end
     @event_plans.push(event_plan)
  end

  def add_plan_id(event_plan_id)
    if (!event_plan_id.nil? && !event_plan_id.empty? )
      if (@events_plans_ids.nil? || @events_plans_ids.empty?)
        @events_plans_ids = Array.new
      end
      if (!@events_plans_ids.include?(event_plan_id))
        @events_plans_ids.push(event_plan_id)
      end


    end
  end
  def has_attendees
    return !@attendees_phones.nil?   && !@attendees_phones.empty?
  end
  def add_plans(new_plans_objects)
    puts "OLD PLANS IDS #{@events_plans_ids}"
    if (!new_plans_objects.nil? && !new_plans_objects.empty?)
      new_plans_objects.each do |new_plans|
        if (new_plans.is_valid_plan)
          add_plan_id(new_plans.id)
          add_plan(new_plans)
        end
      end
      puts "NEW PLANS IDS #{@events_plans_ids}"
      AwsDynamodb.update_record_by_hash("event","event_plans",@events_plans_ids,[:id, :string],@id)

    end
  end
  def attendees
    return (@attendees.nil?)? Array.new : @attendees
  end
  def attendees_phones
    return (@attendees_phones.nil?)? Array.new : @attendees_phones
  end
  def add_attendee(attendee)
    if (!attendee.nil? && attendee.valid_attendee )
      if (@attendees.nil? || @attendees.empty?)
        @attendees = Array.new
      end

      @attendees.push(attendee)
    end
  end
  def add_attendee_phone(attendee_phone)
    if (!attendee_phone.nil? && !attendee_phone.empty? )
      if (@attendees_phones.nil? || @attendees_phones.empty?)
        @attendees_phones = Array.new
      end
      if (!@attendees_phones.include?(attendee_phone))
        @attendees_phones.push(attendee_phone)
      end


    end
  end
  def set_title(title)
    @title = title
  end
  def change_event_title(new_title)

    if (!new_title.nil? && !new_title.empty?)
      set_title(new_title)
      AwsDynamodb.update_record_by_hash("event","title",@title,[:id, :string],@id)

    end
  end
  def add_attendees(new_users_attendees_objects)
    if (!new_users_attendees_objects.nil? && !new_users_attendees_objects.empty?)
      new_users_attendees_objects.each do |attendee_user_object|
        if (attendee_user_object.valid_attendee)
          add_attendee_phone(attendee_user_object.phone_number)
          add_attendee(attendee_user_object)
        end
      end
      AwsDynamodb.update_record_by_hash("event","attendees",@attendees_phones,[:id, :string],@id)

    end
  end
  def  created_at
    return (@created_at.nil?)? Time.now.to_f : @created_at
  end
  def event_attendees_push_end_points
    return (@event_attendees_push_end_points.nil?)? Array.new : @event_attendees_push_end_points
  end
  def event_plan_id
    return (@event_plan_id.nil?)? "" :  @event_plan_id
  end
  def events_plans_ids

    return (@events_plans_ids.nil?)? Array.new : @events_plans_ids
  end

  def add_event_plan_id(event_plan_id)
    if (@events_plans_ids.nil? || @events_plans_ids.empty?)
      @events_plans_ids = Array.new
    end

    if (!event_plan_id.nil? && !event_plan_id.empty? && !@events_plans_ids.include?(event_plan_id))
      @events_plans_ids.push(event_plan_id)
    end

  end
  def add_event_plan(event_plan)
    if (@event_plans.nil? || @event_plans.empty?)
      @event_plans = Array.new
    end

    if (!event_plan.nil? && !event_plan.id.nil? && !event_plan.id.empty?)
      @event_plans.push(event_plan)
    end

  end
  def event_plans
    return (@event_plans.nil?)? Array.new : @event_plans
  end

  def phone_number
    return (@phone_number.nil?)? "" : @phone_number
  end
  def   status
    return (@status.nil?)? "" : @status
  end
  def set_booked_plan_id(event_plan_id)
    if(!event_plan_id.nil? && !event_plan_id.empty? && !@events_plans_ids.nil? && @events_plans_ids.include?(event_plan_id))
      @event_plan_id = event_plan_id

    end
  end
  def set_booked_status
    @status = "booked"
  end
  def set_canceled_status
    @status = "canceled"
  end

  def title
    return (@title.nil?)? "" : @title
  end
  def update_at
    return (@update_at.nil?)? Time.now.to_f : @update_at
  end
  def user_id
    return (@user_id.nil?)? "" : @user_id
  end
  def update_booked_event

    set_booked_status

    AwsDynamodb.update_record_attributes("event",{:status => @status, :event_plan_id =>@event_plan_id, :updated_at => Time.now.to_f},@id)

  end
  def update_canceled_event

    set_canceled_status
    AwsDynamodb.update_record_attributes("event",{:status => @status, :updated_at => Time.now.to_f},@id)
  end
  def in_event(user)
    return @attendees_phones.include?(user.phone_number)
  end

  def self.new_event_record_from_hash_message(message,user_inviter)
    event = AwsEvent.new
    if (!user_inviter.nil? && user_inviter.valid_user)

    event.internal_new_from_message(message)
    if (message.has_key?("event_plans") && !message["event_plans"].empty?)
      set_event_plans_from_message(message["event_plans"], event)
    end

    if (message.has_key?("attendees") && !message["attendees"].empty?)
      set_event_attendees_from_message(message["attendees"], event, user_inviter)
    end


    end
    return event

  end
  def self.set_event_plans_from_message(event_plan_messages,event,organizer_phone=nil)
    if (!event_plan_messages.nil? && !event_plan_messages.empty?)
      event_plan_messages.each do |event_plan_message|

        event_plan = AwsEventPlan.get_event_plan_objects_from_message(event_plan_message,event,organizer_phone)
        if (!event_plan.nil? && event_plan.is_valid_plan)
          event.add_event_plan_id(event_plan.id)
          event.add_event_plan(event_plan)
        end

      end
    end


  end

  def self.set_event_attendees_from_message(attendees_message, event,inviter = nil)
       if (!attendees_message.nil? && !attendees_message.empty?)
         attendees_phones = Array.new
         attendees_hash_messages = Hash.new
         attendees_message.each do |attendee_message|
            attendee = AwsUser.set_user(attendee_message)
            attendees_hash_messages[attendee.phone_number] = attendee
            attendees_phones.push(attendee.phone_number )
         end

         attendees_hash = AwsUser.get_users_by_phone(attendees_phones)

         if (!attendees_hash.nil? && !attendees_hash.empty?)
           attendees_hash_messages.each do |attendee_phone, attendee_aws_user|
               if (!attendee_phone.empty? && attendees_hash.has_key?(attendee_phone))
                     ### attendee is a Clowder user
                 attendees_hash_messages[attendee_phone]  =   attendees_hash[attendee_phone]

               else
                 ### attendee is not  a Clowder user

               end
             if (!event.nil?)
               event.add_attendee(attendees_hash_messages[attendee_phone])

               event.add_attendee_phone(attendees_hash_messages[attendee_phone].phone_number)
             end


           end
         end

       end
       ### add the event inviter ...
       if (!inviter.nil?)

         if (!event.nil?)
           event.add_attendee(inviter)
           event.add_attendee_phone(inviter.phone_number)
         end
       end


  end
  def set_event_plans_from_ids
    if (!@events_plans_ids.nil? && !@events_plans_ids.empty?)
      events_plans = AwsEventPlan.get_event_plans_from_db_by_ids(@id, @events_plans_ids)
      if (!events_plans.nil?)
        @event_plans = events_plans
      end

    end
  end
  def internal_new_from_message(message)
    puts "MESSAGE #{message}"
    if (!message.nil? && !message.empty?)
      @id = (message.has_key?("event_id"))? message["event_id"] : ""
      puts "EVENT ID #{@id}"
      #@attendees = (message.has_key?("attendees"))? message["attendees"] : []
      @status= (message.has_key?("status"))? message["status"] : "pending"
      @title = (message.has_key?("title"))? message["title"] : "Meeting"
      #@events_plans_ids = (message.has_key?("events_plans"))? message["events_plans"] : []
      @event_plan_id = (message.has_key?("event_plan_id"))? message["event_plan_id"] : ""
      @user_id = (message.has_key?("user_id"))? message["user_id"] : ""
      @phone_number = (message.has_key?("phone_number"))? message["phone_number"] : ""
      @event_attendees_push_end_points = (message.has_key?("event_attendees_push_end_points"))? message["event_attendees_push_end_points"] : []
      begin
      @created_at = (message.has_key?("created_at") && !message["created_at"].nil? && !message["created_at"].empty?)? DateTime.rfc3339(message["created_at"]).to_f : Time.now.to_f
      rescue
        @created_at = Time.now.to_f
      end
      begin
      @update_at = (message.has_key?("update_at") && !message["update_at"].empty?)? DateTime.rfc3339(message["update_at"]).to_f : Time.now.to_f
      rescue
        @update_at = Time.now.to_f
      end

    end
  end
  def internal_new_from_db_record(message)



    if (!message.nil? && !message.empty?)
      @id = (message.has_key?("id"))? message["id"] : ""
      @attendees_phones = (message.has_key?("attendees"))? message["attendees"].to_a : []
      @status= (message.has_key?("status"))? message["status"] : "pending"
      @title = (message.has_key?("title"))? message["title"] : "Meeting"
      @events_plans_ids = (message.has_key?("event_plans") && !message["event_plans"].empty?)? message["event_plans"].to_a : []

      @event_plan_id = (message.has_key?("event_plan_id"))? message["event_plan_id"] : ""
      @user_id = (message.has_key?("user_id"))? message["user_id"] : ""
      @phone_number = (message.has_key?("phone_number"))? message["phone_number"] : ""
      @event_attendees_push_end_points = (message.has_key?("event_attendees_push_end_points"))? message["event_attendees_push_end_points"].to_a : []
      @created_at = (message.has_key?("created_at") )? message["created_at"] : Time.now.to_f
      @update_at = (message.has_key?("update_at") )? message["update_at"] : Time.now.to_f


    end
  end

  ##  gets an event_id ,search for it on AWS events table and sets the event objects properties accordingly
  def self.set_event_record_from_db(event_id,consistent_read =false)

    e = AwsEvent.new
    event_record = AwsDynamodb.get_record_from_table_name_by_hash_key_value("event",event_id)
    e.internal_new_from_db_record(event_record)
    #new_event_record_from_hash_message(event_record)
    return e
  end

  # save event message as gotten from the json messsage from the app side to the event table on AWS if valid
  def save_event_record_to_db()

    saved = false
    valid_event_message = get_valid_event_record_from_properties()
    if(!valid_event_message.nil? && !valid_event_message.empty?)
      saved = AwsDynamodb.save_record("event",valid_event_message)
    end
    return saved
  end
  # save event to AWS event table ,from properties
  def save_event_to_db(event)
    saved = false
     if (!event.nil?)
       valid_event_message = event.get_valid_event_record_from_properties()
       if(!valid_event_message.nil? && !valid_event_message.empty?)
         saved = AwsDynamodb.save_record("event",valid_event_message)
       end
     end

    return saved
  end
  #def cancel_event_event_plan_user
  #
  #  @events_plans_ids.each do|event_plan_id|
  #    puts "EVENT PLAN ID #{event_plan_id} PHONES #{attendees_phone_numbers}"
  #    AwsDynamodb.update_record_attributes_with_range("event_plan_user",{:status => "no", :status_datetime => Time.now.to_f, :updated_at => Time.now.to_f},[:event_plan_id, :string],event_plan_id,[:phone_number, :string],attendees_phone_numbers)
  #  end
  #
  #end
  def is_valid_for_book(booker_phone)
    #puts "ID #{@id} @event_plan_id #{@event_plan_id} @phone_number #{@phone_number} @title #{@title} "
    return !@id.nil? && !@event_plan_id.nil? && !@phone_number.nil?  && !@title.empty? && !@id.empty? && !@event_plan_id.empty? && !@phone_number.empty? && @phone_number==booker_phone && !@title.empty?
  end

  #def is_valid_for_cancel
  #  return !@event_plans_ids.nil? && !@event_plans_ids.empty? && !@attendee_phone_number.nil? && !@attendee_phone_number.empty?
  #
  #  end
  def is_valid_event
    #puts "ID #{@id}  @phone_number #{@phone_number} @title #{@title} "

  return (!@title.nil? && !@title.empty? && !@id.nil? && !@id.empty? && !@phone_number.nil? && !@phone_number.empty?)

  end
  ## create an hash valid event record to be saved on AWS event table
  def get_valid_event_record_from_properties()
    event_record = Hash.new
    # event record must have event_id,title & phone number (of the organizer)
    if (!@title.nil? && !@title.empty? && !@id.nil? && !@id.empty? && !@phone_number.nil? && !@phone_number.empty?)
      event_record["id"] = @id
      event_record["phone_number"] = @phone_number
      event_record["created_at"] = (!@created_at.nil? )? @created_at: Time.now.to_f
      event_record["updated_at"] = (!@update_at.nil? )? @update_at: Time.now.to_f
      event_record["status"] = (!@status.nil? && !@status.empty?)? @status: "pending"      ### default value
      event_record["title"] = @title
                                                                                           ### can only add keys with a non empty values to Dynamo...
      if (!@attendees_phones.nil? && !@attendees_phones.empty?)
        event_record["attendees"] = @attendees_phones
      end
      if (!@event_plan_id.nil? && !@event_plan_id.empty?)
        event_record["event_plan_id"] = @event_plan_id
      end
      if (!@events_plans_ids.nil? && !@events_plans_ids.empty?)
        event_record["event_plans"] = @events_plans_ids
      end

      if (!@user_id.nil? && !@user_id.empty?)
        event_record["user_id"] = @user_id
      end

      if  (!@event_attendees_push_end_points.nil? && !@event_attendees_push_end_points.empty?)
        event_record["event_attendees_push_end_points"] = @event_attendees_push_end_points
      end
    end
    return event_record

  end



end