class  AwsNonUsers

  @phone_number

  @first_name
  @last_name

  @created_at

  @inviter_device_tokens_arns
  @inviter_phone_number

  @updated_at
  def new

  end

  def phone_number
    return (@phone_number.nil?)? "": @phone_number
  end


  def first_name
    return (@first_name.nil?)? "": @first_name
  end
  def last_name
    return (@last_name.nil?)? "" : @last_name
  end




  def created_at
    return (@created_at.nil?)? Time.now.to_f: @created_at
  end


  def inviter_device_tokens_arns
    return (@inviter_device_tokens_arns.nil?)? Array.new : @inviter_device_tokens_arns
  end


  def inviter_phone_number
    return (@inviter_phone_number.nil?)? "" :@inviter_phone_number
  end
  def updated_at
    return (@updated_at.nil?)? Time.now.to_f : @updated_at
  end

  def self.set_non_user(user_message,inviter)
    user = AwsNonUsers.new
    if (!inviter.nil? && inviter.valid_user)
      user_message["inviter_device_tokens_arns"]  = inviter.device_tokens_arns
      user_message["inviter_phone_number"]  = inviter.phone_number
    end

    user.internal_new_from_message(user_message)
    return user

  end

  def internal_new_from_message(message)
    #puts "USER MESSAGE #{message}"
    @phone_number  = (!message.nil? && !message.empty? && message.has_key?("phone_number")) ? message["phone_number"] :""

    @first_name  =(!message.nil? && !message.empty? && message.has_key?("first_name")) ? message["first_name"] :""
    @last_name =(!message.nil? && !message.empty? && message.has_key?("last_name")) ? message["last_name"] :""

    @updated_at   = (message.has_key?("updated_at") )? message["updated_at"] : Time.now.to_f
    @created_at   = (message.has_key?("created_at") )? message["created_at"] : Time.now.to_f

    if (message.has_key?("inviter_device_tokens_arns") && !message["inviter_device_tokens_arns"].empty?)
      #puts "USER MESSAGE #{message["device_tokens"].to_a}"
      @inviter_device_tokens_arns   =  message["inviter_device_tokens_arns"].to_a
      #puts "USER MESSAGE #{@device_tokens}"
    end
    if (message.has_key?("inviter_phone_number") && !message["inviter_phone_number"].empty?)
      @inviter_phone_number   =  message["inviter_phone_number"]
    end




  end
  def self.verify_user_on_non_users_table(phone_number)
    non_user = AwsNonUsers.new
    if (!phone_number.nil? && !phone_number.empty?)


      current_user_record = AwsDynamodb.get_record_from_table_name_by_hash_key_value("non_users",phone_number,[:phone_number, :string])


      non_user.internal_new_from_message(current_user_record)

    end
    return non_user

  end
  def upadte_time
    record["updated_at"] =Time.now.to_f
  end


  def save_non_user
    non_user_record = get_non_user_record

    if (!non_user_record.empty?)

      upadte_time
      AwsDynamodb.save_all_records("non_users",[non_user_record])

    end
  end

  def self.save_all_non_user(non_users)
    non_user_records = Array.new
    non_users.each do |non_user|
      non_user_record = non_user.get_non_user_record
      if (!non_user_record.empty?)
        non_user_records.push(non_user_record)
      end

    end

      AwsDynamodb.save_all_records("non_users",non_user_records)

    end

  def get_non_user_record
    record = Hash.new
    if (valid_non_user)
      record["phone_number"] = @phone_number

      record["first_name"] =@first_name
      record["last_name"] =@last_name

      record["created_at"] =@created_at

      record["inviter_device_tokens_arns"] =@inviter_device_tokens_arns
      record["inviter_phone_number"] =@inviter_phone_number

      record["updated_at"] =@updated_at

    end
    return record
  end


  # an attendee ,must have properties
  def valid_attendee
    #puts "USER DEVICE TOKENS #{@device_tokens}"
    return (!@phone_number.nil? && !@phone_number.empty? )#&& !@first_name.nil? && !@first_name.empty? && !@last_name.nil? && !@last_name.empty?)
  end
  # a non user ,must have properties
  def valid_non_user
    #puts "VALID USER - USER DEVICE TOKENS #{@device_tokens} #{@first_name} #{@phone_number} #{@last_name} "
    return (!@phone_number.nil? && !@phone_number.empty? && !@first_name.nil? && !@first_name.empty? && !@last_name.nil? && !@last_name.empty? )

  end
  def valid_inviter
    return (!@inviter_device_tokens_arns.nil? && !@inviter_device_tokens_arns.empty? && !@inviter_phone_number.nil? && !@inviter_phone_number.empty?)
  end
  def get_inviter
    inviter_devices = Array.new

    #puts  "VALID INVITER???? #{@inviter_device_tokens_arns} == #{@inviter_phone_number}"

    if (valid_inviter)
      puts  "VALID INVITER"
      devices_tokens_arns  =  @inviter_device_tokens_arns
      #inviter_phone =  @inviter_phone

      devices_tokens_arns.each do |device_arn|
        inviter = AwsUsersDeviceTokens.new
        if (!device_arn.nil? && !device_arn.empty?)
          record = Hash.new
          record["phone_number"] = @inviter_phone_number
          record["device_token_arn"] = device_arn
          record["device_token"] = ""
          inviter.setup_user_device_token_from_record(record)
          inviter_devices.push(inviter)
        end
      end

    end
    return inviter_devices

  end
  def delete_non_user
    AwsDynamodb.delete_records("non_users", {:phone_number => @phone_number},[:phone_number, :string])

  end
  def self.process_non_users(new_users_attendees_objects,user)
    non_users = Array.new
    if (!new_users_attendees_objects.nil?)
    new_users_attendees_objects.each do |new_attendee|
      if (new_attendee.valid_non_user)
        user_message = Hash.new
        user_message["phone_number"] = new_attendee.phone_number
        user_message["first_name"]= new_attendee.first_name
        user_message["last_name"] = new_attendee.last_name

        non_user = AwsNonUsers.set_non_user(user_message,user)

      end

      if (!non_user.nil? && non_user.valid_non_user)
        non_users.push(non_user)
      end
    end
    if (!non_users.nil? && !non_users.empty?)
      save_all_non_user(non_users)
    end
    end
    end
  end