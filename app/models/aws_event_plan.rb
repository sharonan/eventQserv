class AwsEventPlan

  @id   #event_plan_id
  @event_id
  @created_at
  @dtstart
  @duration
  @latitude
  @location
  @location_title
  @title
  @longitude
  @updated_at
  @event_organizer_id
  @event_organizer_phone
  @event_plan_organizer_phone
  @event_plan_organizer_user_id

  def new

  end
  def id
    return @id
  end

  def event_id
    return @event_id
  end
  def  created_at
    return @created_at
  end
  def dtstart
    return @dtstart
  end
  def duration
    return @duration
  end
  def latitude
    return @latitude
  end

  def location
    return @location
  end
  def   location_title
    return @location_title
  end
  def title
    return @title
  end
  def longitude
    return @longitude
  end
  def updated_at
    return @updated_at
  end
  def event_organizer_id
    return @event_organizer_id
  end

  def event_organizer_phone
    return @event_organizer_phone
  end

  def event_plan_organizer_phone
    return @event_plan_organizer_phone
  end

  def event_plan_organizer_user_id
    return @event_plan_organizer_user_id
  end

  def self.new_event_plan_record_from_hash_message(message,event,event_plan_organizer=nil)
    event_plan = AwsEventPlan.new
    puts "MESSAGE #{message}"
    event_plan.internal_new_from_message(message,event,event_plan_organizer)

    return event_plan
  end

  def internal_new_from_message(message,event,event_plan_organizer=nil)
    if (!message.nil? && !message.empty? && !event.nil?  && !event.phone_number.nil?)
      @event_id = (!event.id.nil?)? event.id : ""

      @location_title= (message.has_key?("location_title"))? message["location_title"] : ""
      @location= (message.has_key?("location"))? message["location"] : ""
      @title = (message.has_key?("title"))? message["title"] : (!event.title.nil?)? event.title : "Meeting"

      @longitude = (message.has_key?("longitude"))? message["longitude"] : nil
      @latitude = (message.has_key?("latitude"))? message["latitude"] : nil
      @duration = (message.has_key?("duration"))? message["duration"] : 0
      @dtstart = (message.has_key?("dtstart"))? DateTime.rfc3339(message["dtstart"]).to_f : Time.now.to_f

      @id = (message.has_key?("event_plan_id"))? message["event_plan_id"] : ""
      @event_organizer_id = (!event.user_id.nil? )? event.user_id : ""
      @event_organizer_phone = (!event.phone_number.nil?)? event.phone_number : ""
      ## event plan organizer default to the event organizer
      @event_plan_organizer_phone = (!event_plan_organizer.nil? && !event_plan_organizer.phone_number.empty?)? event_plan_organizer.phone_number: (!event.phone_number.empty?)? event.phone_number : ""
      @event_plan_organizer_user_id = (!event_plan_organizer.nil? && !event_plan_organizer.user_id.empty?)? event_plan_organizer.user_id: (!event.user_id.empty?)? event.user_id : ""

      @created_at = (message.has_key?("created_at") && !message["created_at"].empty?)? DateTime.rfc3339(message["created_at"]).to_f : Time.now.to_f
      @updated_at = (message.has_key?("updated_at") && !message["updated_at"].empty?)? DateTime.rfc3339(message["updated_at"]).to_f : Time.now.to_f


    end
  end
  def new_event_plan_record_from_db(message,event=nil)
    #puts "MESSAGE #{message}"
    if (!message.nil? && !message.empty? )
      @event_id = (!event.nil? && !event.id.nil?)? event.id : ""

      @location_title= (message.has_key?("location_title"))? message["location_title"] : ""
      @location= (message.has_key?("location"))? message["location"] : ""
      @title = (message.has_key?("title"))? message["title"] : (!event.title.nil?)? event.title : "Meeting"

      @longitude = (message.has_key?("longitude"))? message["longitude"] : nil
      @latitude = (message.has_key?("latitude"))? message["latitude"] : nil
      @duration = (message.has_key?("duration"))? message["duration"] : 0
      @dtstart = (message.has_key?("dtstart"))? message["dtstart"] : Time.now.to_f

      @id = (message.has_key?("id"))? message["id"] : ""

      @event_organizer_id = (message.has_key?("event_organizer_id"))? message["event_organizer_id"] : ""
      @event_organizer_phone = (message.has_key?("event_organizer_phone"))? message["event_organizer_phone"] : ""
      @event_plan_organizer_phone = (message.has_key?("event_plan_organizer_phone"))? message["event_plan_organizer_phone"]: (!event.nil? && !event.phone_number.nil?)? event.phone_number : ""
      @event_plan_organizer_user_id = (message.has_key?("event_plan_organizer_user_id"))? message["event_plan_organizer_user_id"]: (!event.nil? && !event.user_id.nil?)? event.user_id : ""


      @created_at = (message.has_key?("created_at") )? message["created_at"] : Time.now.to_f
      @updated_at = (message.has_key?("updated_at") )? message["updated_at"] : Time.now.to_f


    end
  end

  def self.save_event_plans(event_plans)
    if (!event_plans.nil?)
      valid_events_plans = Array.new
      event_plans.each do |event_plan|
         if (event_plan.is_valid_plan)
           valid_events_plans.push(event_plan.get_valid_event_plan_record_from_properties())
         end
      end


    end
    AwsDynamodb.save_all_records("event_plan",valid_events_plans)

  end
  # gets an event object and array of event_plan messages  saves all event_plan records to AWS
  # and return an array of event_plan_id's saved
  def self.generate_and_save_event_plans_records(event_plans,event,event_plan_organizer=nil)


    if (!event_plans.nil?)
      valid_events_plans = Array.new

      event_plans.each do |event_plan|

        event_plan_object = new_event_plan_record_from_hash_message(event_plan,event,event_plan_organizer)

        event.add_plan(event_plan_object)
        event.add_event_plan_id(event_plan_object.id)

        valid_events_plans.push(event_plan_object.get_valid_event_plan_record_from_properties())
        event_plan_object.get_valid_event_plan_record_from_properties()

        puts "EVENT PLAN #{event_plan_object}"
      end

      AwsDynamodb.save_all_records("event_plan",valid_events_plans)

    end

  end

  def self.get_event_plan_objects_from_message(event_plans_message, event,event_plan_organizer=nil)
    #valid_events_plans = Array.new
    if (!event_plans_message.nil? && !event_plans_message.empty? && !event.nil? && event.is_valid_event)


      #event_plans_message.each do |event_plan|

        event_plan_object = new_event_plan_record_from_hash_message(event_plans_message,event,event_plan_organizer)

        #event.add_plan(event_plan_object)
        #event.add_event_plan_id(event_plan_object.id)

        #valid_events_plans.push(event_plan_object)
        event_plan_object.get_valid_event_plan_record_from_properties()

        #puts "EVENT PLAN #{event_plan}"
        puts "EVENT PLAN properties hash #{event_plan_object.get_valid_event_plan_record_from_properties()}"
      #end
      #AwsDynamodb.save_all_records("event_plan",valid_events_plans)

    end
    return event_plan_object
  end

  def self.get_event_plan_from_db(event, event_plan_id)

    plan_record = AwsDynamodb.get_record_by_hash_and_range_key("event_plan",[:event_id, :string],[:id, :string],event.id,event_plan_id)
    event_plan = AwsEventPlan.new

    event_plan.new_event_plan_record_from_db(plan_record,event)
    event_plan.get_valid_event_plan_record_from_properties()
    return  event_plan

  end

  def self.get_event_plans_from_db_by_ids(event_id, events_plans_ids=[])
    puts "EVENTS PLANS IDS #{events_plans_ids}"
    events_plans_ids = (events_plans_ids.nil? || events_plans_ids.empty?)? [] :events_plans_ids
    event_plans = Array.new
    if (!events_plans_ids.empty?)
      plans_records = AwsDynamodb.get_all_range_records_by_hash("event_plan",[event_id])

      puts "PLANS  ==  #{plans_records}"
      plans_records.each do |plan_record|
        event_plan = AwsEventPlan.new
        puts "PLAN RECORD #{plan_record}"
        event_plan.new_event_plan_record_from_db(plan_record,nil)
        #event_plan.get_valid_event_plan_record_from_properties()
        puts "PLANS ID ==  #{event_plan.id} PLAN == #{event_plan}"
        if  (events_plans_ids.include?(event_plan.id))

          event_plans.push(event_plan)
        end
      end

    end
    puts "EVENT PLANS #{event_plans}"
    return  event_plans

  end
  def self.update_event_plan_edit(event_id, event_plan_id,old_event_plan_id)
    #AwsDevDynamodb.new
    return AwsDynamodb.update_record_attributes_with_range("event_plan",{:status => 'replaced', :replaced_by => event_plan_id,:status_datetime => Time.now.to_f, :updated_at => Time.now.to_f},[:id, :string],event_id,[:event_plan_id, :string],old_event_plan_id)
  end
  def is_valid_plan
    puts "EVENT_PLAN_ID #{@id} EVENT_ID #{@event_id} ORGANIZER #{@event_organizer_phone}"
    return !@id.empty?  && !@event_organizer_phone.empty?
  end
  ## create an hash valid event record to be saved on AWS event table
  def get_valid_event_plan_record_from_properties()
    event_record = Hash.new
    # event record must have event_id,title & phone number (of the organizer)
    if ( !@id.nil? && !@id.empty? && !@event_id.nil? && !@event_id.empty?)
      event_record["id"] = @id
      event_record["event_id"] = @event_id

      event_record["event_organizer_phone"] = @event_organizer_phone
      event_record["event_organizer_user_id"] = @event_plan_organizer_user_id
      event_record["event_plan_organizer_phone"] = @event_plan_organizer_phone
      event_record["event_organizer_id"] = @event_organizer_id
      event_record["dtstart"] = (!@dtstart.nil? )? @dtstart: Time.now.to_f
      event_record["duration"] = (!@duration.nil? )? @duration: 0
      event_record["created_at"] = (!@created_at.nil? )? @created_at: Time.now.to_f
      event_record["updated_at"] = (!@updated_at.nil? )? @updated_at: Time.now.to_f
      event_record["title"] = @title
                                                                                           ### can only add keys with a non empty values to Dynamo...
      if (!@location_title.nil? && !@location_title.empty?)
        event_record["location_title"] = @location_title
      end
      if (!@location.nil? && !@location.empty?)
        event_record["location"] = @location
      end
      if (!@longitude.nil? )
        event_record["longitude"] = @longitude
      end

      if (!@latitude.nil?)
        event_record["latitude"] = @latitude
      end


    end
    return event_record

  end
end