class AwsUsersEvents

  @id
  @event_id


  def new

  end
  def id
    return (@id.nil?)? "" : @id
  end
  def event_id
    return (@event_id.nil?)? "" : @event_id
  end
  def self.save_users_events(users_events)
    #users_events = Array.new
    if (!users_events.nil? && !users_events.empty?)
      users_events.each do |user_event|
        if (!user_event.valid_user_event)
          users_events.delete(user_event)
        end
        AwsDynamodb.save_all_records("users_events",users_events)
      end
    end

  end
  def self.save_users_events_from_users_phones(users_phones,event_id)
    users_events = Array.new
    users_events_hash_records = Array.new
    if (!users_phones.nil? && !users_phones.empty? && !event_id.nil? && !event_id.empty?)

      users_phones.each do |user_phone|

        if (!user_phone.nil? && !user_phone.empty?)
          user_event = AwsUsersEvents.new
          user_event.set_user_event(user_phone, event_id)
          users_events.push(user_event)
          record = Hash.new
          record["id"] = user_phone
          record["event_id"] = event_id
          users_events_hash_records.push(record)

        end
      end
      AwsDynamodb.save_all_records("users_events",users_events_hash_records)

    end

  end
  def valid_user_event
    return !@id.empty? && !@event_id.empty?
  end
  def set_user_event(phone_number, event_id)
    @id = (!phone_number.nil? && !phone_number.empty?)? phone_number : ""
    @event_id = (!event_id.nil? && !event_id.empty?)? event_id : ""
  end

  def self.update_user_event_table(event_users, event_id)
    if (!event_id.empty? && !event_users.empty?)
      #AwsDevDynamodb.new
      user_event_records = Array.new
      event_users.each do|event_user|
        if (event_user.valid_attendee)
          user_event_record = Hash.new
          user_event_record["id"] = event_user.phone_number
          user_event_record["event_id"] = event_id
          user_event_records.push(user_event_record)

        end

      end
      if (!user_event_records.empty?)
        return AwsDynamodb.save_all_records("users_events",user_event_records)
      else
        return false
      end
    else
      return false
    end

  end
end