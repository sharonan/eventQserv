class AwsEventPlanUser

  @event_plan_id
  @phone_number
  @created_at
  @id
  @organizer_id
  @organizer_phone
  @attendee_user_id
  @role
  @status
  @status_datetime
  @updated_at




  def event_plan_id
    return @event_plan_id
  end

  def phone_number
    return @phone_number
  end

  def created_at
    return @created_at
  end

  def id
    return @id
  end


  def organizer_id
    return @organizer_id
    end

  def attendee_user_id
    return @attendee_user_id
  end

  def organizer_phone
    return @organizer_phone
  end

  def role
    return @role
  end

  def status
    return @status
  end

  def status_datetime
    return @status_datetime
  end

  def updated_at
    return @updated_at
  end

  ## Gets aws_users and aws_event_plans
  ## Return Array of valid aws_event_plan_users
  def self.setup_event_plan_user_from_plans_for_event_users(event_users, event_plans)
    event_plan_user_records = Array.new
    if (!event_plans.nil? && !event_users.nil? && !event_users.empty?)
      event_plans.each do |event_plan|
        if (event_plan.is_valid_plan)
          event_users.each do|event_user|

            if (event_user.valid_attendee)
              event_plan_user = AwsEventPlanUser.new
               event_plan_user.internal_from_event_plan(event_user,event_plan)

              if (event_plan_user.valid_event_plan_user)
                event_plan_user_records.push(event_plan_user)
              end

            end

          end
        end

      end

    end
    return event_plan_user_records
  end

  def self.save_event_plan_user_from_plans_for_event_users(event_users, event_plans)
    puts "EVENT USERS -----  #{event_users} VENT USERS PLAN -----  #{event_plans}"
    event_plan_user_records = Array.new
    if (!event_plans.nil? && !event_users.nil? && !event_users.empty?)
      event_plans.each do |event_plan|


        if (event_plan.is_valid_plan)

          event_users.each do|event_user|

            if (event_user.valid_attendee)
              event_plan_user = AwsEventPlanUser.new
              event_plan_user.internal_from_event_plan(event_user,event_plan)
              if (event_plan_user.valid_event_plan_user)
                event_plan_user_records.push(event_plan_user)
              end

            end

          end
        end

      end

    end

    save_event_plan_users(event_plan_user_records)
  end

  def self.save_event_plan_user_from_plans_for_current_event_users(event, event_plans)
    event_plan_user_records = Array.new
    if (!event_plans.nil? && !event.nil? && event.is_valid_event)
      event_plans.each do |event_plan|

        if (event_plan.is_valid_plan)
          attenedes_users_hash_records = AwsUser.get_users_by_phone(event.attendees_phones)

          puts "attenedes_users_hash_records === #{attenedes_users_hash_records}"
          event.attendees_phones.each do|event_user_phone|
            if (!event_user_phone.empty?)
              event_plan_user = AwsEventPlanUser.new
              attendee = AwsUser.new
              attendee.set_phone_number(event_user_phone)
              attendee.set_user_id("")
              if (attenedes_users_hash_records.has_key?(event_user_phone) )
                puts "ATTENDEE #{attenedes_users_hash_records[event_user_phone]}"
                attendee =  attenedes_users_hash_records[event_user_phone]
              end
              event_plan_user.internal_from_event_plan(attendee,event_plan)
              if (event_plan_user.valid_event_plan_user)
                event_plan_user_records.push(event_plan_user)
              end

            end

          end
        end

      end

    end
    puts "SAVE ..... #{event_plan_user_records}"
    save_event_plan_users(event_plan_user_records)
  end

  ## Gets aws_event
  ## Return Array of aws_event_plan_user objects from the aws_event_plans set on that aws_event properties (event_plans)
  def self.setup_event_plan_user_from_event(event)
    event_plan_users = Array.new
    if (!event.nil? && !event.event_plans.nil? && !event.event_plans.empty?  && !event.attendees.nil? && !event.attendees.empty?)

      event_plan_users = setup_event_plan_user_from_plans_for_event_users(event.attendees, event.event_plans)

    end
    return event_plan_users
  end

  ## Gets Array of event_plan_user records (Hash properties)
  ## Return Array of  aws_event_plan_user objects
  def new_event_plan_user_from_records(event_plan_user_records)
    event_plan_users = Array.new
    if (!event_plan_user_records.nil? && !event_plan_user_records.empty? )
      event_plan_user_records.each do |event_plan_user_record|
        if (!event_plan_user_record.nil? && !event_plan_user_record.empty? )
          event_plan_user = AwsEventPlanUser.new
          event_plan_user.internal_from_event_plan_user_record(event_plan_user_record)
          event_plan_users.push(event_plan_users)

        end
      end
    end

    return  event_plan_users
  end
  def internal_from_event_plan_user_record(event_plan_user_record)
    if (!event_plan_user_record.nil? && !event_plan_user_record.empty? )
      @event_plan_id  = (event_plan_user_record.has_key?("event_plan_id"))? event_plan_user_record["event_plan_id"] : ""
      @phone_number = (event_plan_user_record.has_key?("phone_number"))? event_plan_user_record["phone_number"] : ""
      @attendee_user_id = (event_plan_user_record.has_key?("attendee_user_id"))? event_plan_user_record["attendee_user_id"] : ""
      @created_at = (event_plan_user_record.has_key?("created_at") )? event_plan_user_record["created_at"] : Time.now.to_f
      @updated_at = (event_plan_user_record.has_key?("updated_at") )? event_plan_user_record["updated_at"] : Time.now.to_f
      @organizer_id = (event_plan_user_record.has_key?("organizer_id"))? event_plan_user_record["organizer_id"] : ""
      @organizer_phone  = (event_plan_user_record.has_key?("organizer_phone"))? event_plan_user_record["organizer_phone"] : ""
      @role   = (event_plan_user_record.has_key?("role"))? event_plan_user_record["role"] : ""
      @status  = (event_plan_user_record.has_key?("status"))? event_plan_user_record["status"] : ""
      @status_datetime = (event_plan_user_record.has_key?("status_datetime"))? event_plan_user_record["status_datetime"] : Time.now.to_f
      @id = (event_plan_user_record.has_key?("id"))? event_plan_user_record["id"] : ""

    end
  end
  def internal_from_event_plan(event_user,event_plan)
    puts "internal_from_event_plan"
    if (!event_user.nil? && !event_plan.nil? &&  event_user.valid_attendee && event_plan.is_valid_plan)
      @event_plan_id  = (!event_plan.id.nil?)? event_plan.id : ""
      @phone_number = event_user.phone_number
      @attendee_user_id = (!event_user.user_id.nil? )?event_user.user_id : ""
      puts "ATTENDEE ID = #{@attendee_user_id} PHONE #{@phone_number}"
      @created_at = (!event_plan.created_at.nil? )? event_plan.created_at : Time.now.to_f
      @updated_at = (!event_plan.updated_at.nil? )? event_plan.updated_at : Time.now.to_f
      @organizer_id = (!event_plan.event_plan_organizer_user_id.empty?)? event_plan.event_plan_organizer_user_id : ""
      @organizer_phone  =  (!event_plan.event_plan_organizer_phone.empty?)? event_plan.event_plan_organizer_phone : ""
      @role   =  (event_user.phone_number == @organizer_phone) ? "planner" : "not planner"
      @status  = (event_user.phone_number == @organizer_phone) ? "yes" : "pending"
      @status_datetime = Time.now.to_f
      @id = "#{event_plan.id}-#{event_user.phone_number}"

      end
  end
  def internal_from_event_plan_phone(event_user_phone,event_plan)
    if (!event_user_phone.nil? && !event_plan.nil? &&  !event_user_phone.empty? && event_plan.is_valid_plan)
      @event_plan_id  = (!event_plan.id.nil?)? event_plan.id : ""
      @phone_number = event_user_phone
      @created_at = (!event_plan.created_at.nil? )? event_plan.created_at : Time.now.to_f
      @updated_at = (!event_plan.updated_at.nil? )? event_plan.updated_at : Time.now.to_f
      @organizer_id = (!event_plan.event_plan_organizer_user_id.empty?)? event_plan.event_plan_organizer_user_id : ""
      @organizer_phone  =  (!event_plan.event_plan_organizer_phone.empty?)? event_plan.event_plan_organizer_phone : ""
      @role   =  (event_user_phone == @organizer_phone) ? "planner" : "not planner"
      @status  = (event_user_phone == @organizer_phone) ? "yes" : "pending"
      @status_datetime = Time.now.to_f
      @id = "#{event_plan.id}-#{event_user_phone}"
      @attendee_user_id = (!event_plan.attendee_user_id.nil? )?event_plan.attendee_user_id : ""

    end
  end


  def get_record_from_event_plan_user
        event_plan_user_record = Hash.new
        event_plan_user_record["id"] = @id
        event_plan_user_record["phone_number"] = @phone_number
        event_plan_user_record["attendee_user_id"] = @attendee_user_id
        event_plan_user_record["organizer_phone"] = @organizer_phone
        event_plan_user_record["organizer_id"] =  @organizer_id
        event_plan_user_record["event_plan_id"] = @event_plan_id
        event_plan_user_record["role"] = @role
        event_plan_user_record["status"] = @status
        event_plan_user_record["status_datetime"] =  @status_datetime
        event_plan_user_record["created_at"] =  @created_at
        event_plan_user_record["updated_at"] =  @updated_at

    return event_plan_user_record
  end
  def self.get_user_vote(phone_number,event_plan_id)
      vote = ''

      if (!phone_number.nil? && !event_plan_id.nil? && !phone_number.empty? && !event_plan_id.empty?)

        event_plan_user_record = AwsDynamodb.get_record_by_hash_and_range_key('event_plan_user',[:event_plan_id, :string],[:phone_number, :string],event_plan_id,phone_number)
        if (!event_plan_user_record.nil? && !event_plan_user_record.empty?)
          event_plan_user = AwsEventPlanUser.new
          event_plan_user.internal_from_event_plan_user_record(event_plan_user_record)


          vote =  event_plan_user.status

        end
      end

      return vote

  end
  ## Gets Array of aws_event_plan_users and saves it to DynamoDB event_plan_users table
  def self.save_event_plan_users(event_plan_users)

    if (!event_plan_users.nil? && !event_plan_users.empty?)
       event_plan_users_records = Array.new
      event_plan_users.each do |event_plan_user|
        if (event_plan_user.valid_event_plan_user)
          event_plan_users_records.push( event_plan_user.get_record_from_event_plan_user  )
        end

      end

      if (!event_plan_users_records.nil? && !event_plan_users_records.empty?)
        AwsDynamodb.save_all_records("event_plan_user",event_plan_users_records)


      end

    end
  end

  def valid_event_plan_user
    #puts "@event_plan_id #{@event_plan_id} id #{@id} phone #{@phone_number}"
    return !@event_plan_id.nil? && !@id.nil? &&  !@phone_number.nil? && !@event_plan_id.empty? && !@id.empty? &&  !@phone_number.empty?

  end
  def self.update_event_plan_user(user_phone, event_plan_id, status)

    return AwsDynamodb.update_record_attributes_with_range("event_plan_user",{:status => status, :status_datetime => Time.now.to_f, :updated_at => Time.now.to_f},[:event_plan_id, :string],event_plan_id,[:phone_number, :string],user_phone)
  end

end