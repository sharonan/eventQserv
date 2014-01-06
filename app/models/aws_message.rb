class AwsMessage

  @event_id
  @id
  @content
  @created_at
  @user_id
  @phone_number
  @updated_at


  def new

  end

  def id
    return (@id.nil?)? "" : @id
  end
  def user_id
    return (@user_id.nil?)? "" : @user_id
  end

  def event_id
    return (@event_id.nil?)? "" : @event_id
  end
  def content
    return (@content.nil?)? "" : @content
  end
  def phone_number
    return (@phone_number.nil?)? "" : @phone_number
  end
  def created_at
    return  (@created_at.nil?)? Time.now.to_f : @created_at
  end
  def updated_at
    return (@updated_at.nil?)? Time.now.to_f : @updated_at
  end
   ## Gets Array of aws_messages
  ## saves them to Message table on AWS
  def self.save_messages(messages)
    valid_records = Array.new
    if (!messages.nil? && !messages.empty?)
      messages.each do |message|
        if(!message.nil?)
          puts "MESSAGE RECORD #{message.get_valid_message_record}"
          valid_records.push(message.get_valid_message_record)
        end
      end
      AwsDynamodb.save_all_records("message",valid_records)

    end

  end

  def self.save_valid_messages_from_protocol(chat_messages,event,chat_user_phone_number)
    valid_messages = Array.new
    if (!chat_messages.nil? && !chat_messages.empty? && !event.nil? && event.is_valid_event)
       chat_messages.each do |message_record|
         chat_message = AwsMessage.new
         chat_message.set_message_from_message_record(message_record,event.id,chat_user_phone_number)
         #puts "VALID MESSAGE #{chat_message}"
         if (chat_message.valid_message)
           #puts "VALID MESSAGE #{chat_message}  #{chat_message.created_at}"
           valid_messages.push(chat_message)
         end
       end
    end
    #puts "VALID MESSAGES #{valid_messages}"
    if (!valid_messages.empty?)
      #puts "MESSAGES TO "
      save_messages(valid_messages)
    end
    return  valid_messages
  end
  def get_valid_message_record
    message_record = Hash.new
    if (valid_message)
      message_record["id"] = @id
      message_record["event_id"] = @event_id
      message_record["content"] = @content
      message_record["created_at"] = @created_at
      message_record["updated_at"] = @updated_at
      message_record["user_id"] = @user_id
      message_record["phone_number"] = @phone_number
    end

    return message_record
  end

  ## Gets a message (from chat_message protocol)
  ## Return aws_message object
  def set_message_from_message_record(message_record,event_id,user)

    if (!message_record.nil? && ! message_record.empty? && !user.nil?)
      @event_id =  (!event_id.nil?)? event_id: ""
      @id =  (message_record.has_key?("message_id"))? message_record["message_id"]: ""
      @phone_number =  (user.phone_number.nil?)? "": user.phone_number
      @user_id =  (user.user_id.nil?)? "": user.user_id
      @content = (message_record.has_key?("content"))? message_record["content"]: ""
      @created_at =  (message_record.has_key?("created_at"))? DateTime.rfc3339(message_record["created_at"]).to_f: Time.now.to_f
      @updated_at =  (message_record.has_key?("updated_at"))? DateTime.rfc3339(message_record["updated_at"]).to_f: Time.now.to_f

    end

  end
 def valid_message
   puts "VALID ? EVENT_ID #{@event_id}  ID #{@id}  CONTENT #{@content}  PHONE #{@phone_number} CREATED-AT#{@created_at}"
   return   !@event_id.empty? && !@id.empty? && !@content.empty? && !@phone_number.empty?

 end

end