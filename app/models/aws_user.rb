class AwsUser

  @phone_number
  @user_id
  @first_name
  @last_name

  @created_at
  @device_tokens
  @device_tokens_arns
  @friends_phones
  @password
  @picture_url
  @updated_at

  def new

  end

  def set_user_id(user_id)
    @user_id = user_id
  end
  def set_phone_number(phone_number)
    @phone_number = phone_number
  end


  def phone_number
    return @phone_number
  end

  def picture_url
    return @picture_url
  end
  def user_id
    return @user_id
  end
  def first_name
    return @first_name
  end
  def last_name
    return @last_name
  end




  def created_at
    return @created_at
  end

  def device_tokens
    return @device_tokens
  end
  def add_device_token(device_token)
    if (@device_tokens.nil? || @device_tokens.empty?)
      @device_tokens = Array.new
    end
    if (!device_token.nil? && !device_token.empty?)
      @device_tokens.push(device_token)
    end
  end
  def device_tokens_arns
    return @device_tokens_arns
  end
  def add_device_token_arn(device_token_arn)
    if (@device_tokens_arns.nil? || @device_tokens_arns.empty?)
      @device_tokens_arns = Array.new
    end
    if (!device_token_arn.nil? && !device_token_arn.empty?)
      @device_tokens_arns.push(device_token_arn)
    end
  end
  def friends_phones
    return @friends_phones
  end
  def add_friend_phone(friend_phone)
    if (@friends_phones.nil? || @friends_phones.empty?)
      @friends_phones = Array.new
    end
    if (!friend_phone.nil? && !friend_phone.empty?)
      @friends_phones.push(friend_phone)
    end
  end

  def password
    return @password
  end
  def updated_at
    return @updated_at
  end

  def self.set_user(user_message)
      user = AwsUser.new
      user.internal_new_from_message(user_message)
    return user

  end

  def internal_new_from_message(message)
    #puts "USER MESSAGE #{message}"
    @phone_number  = (!message.nil? && !message.empty? && message.has_key?("phone_number")) ? message["phone_number"] :""
    @picture_url  = (!message.nil? && !message.empty? && message.has_key?("picture_url")) ? message["picture_url"] :""
    @user_id   =(!message.nil? && !message.empty? && message.has_key?("user_id")) ? message["user_id"] :""
    @first_name  =(!message.nil? && !message.empty? && message.has_key?("first_name")) ? message["first_name"] :""
    @last_name =(!message.nil? && !message.empty? && message.has_key?("last_name")) ? message["last_name"] :""

    @updated_at   = (message.has_key?("updated_at") )? message["updated_at"] : Time.now.to_f
    @created_at   = (message.has_key?("created_at") )? message["created_at"] : Time.now.to_f

    #if (message.has_key?("created_at") && !message["created_at"].empty?)
    #  @created_at =  message["created_at"]
    #end
    if (message.has_key?("device_tokens") && !message["device_tokens"].empty?)
      #puts "USER MESSAGE #{message["device_tokens"].to_a}"
      @device_tokens   =  message["device_tokens"].to_a
      #puts "USER MESSAGE #{@device_tokens}"
    end
    if (message.has_key?("device_tokens_arns") && !message["device_tokens_arns"].empty?)
      @device_tokens_arns   =  message["device_tokens_arns"].to_a
    end
    if (message.has_key?("friends_phones") && !message["friends_phones"].empty?)
      @friends_phones   =  message["friends_phones"].to_a
    end
    if (message.has_key?("password") && !message["password"].empty?)
      @password   =  message["password"]
    end



  end
  def self.verify_user_on_users_table(phone_number)
    user = AwsUser.new
    if (!phone_number.nil? && !phone_number.empty?)
      #AwsDevDynamodb.new

      current_user_record = AwsDynamodb.get_record_from_table_name_by_hash_key_value("users",phone_number,[:phone_number, :string])
      #puts "USER #{current_user_record} "

      user.internal_new_from_message(current_user_record)
      #puts "USER #{user.first_name} "
    end
    return user

  end

  def self.save_non_users(non_users)
    if (!non_users.nil? && !non_users.empty?)
      valid_non_users = Array.new
      non_users.each do|non_user|
        if (!non_user.nil? && non_user.valid_attendee)
            non_user_record = Hash.new
            non_user_record["phone_number"]   = non_user.phone_number
            non_user_record["first_name"]   = non_user.first_name
            non_user_record["last_name"]   = non_user.last_name
            non_user_record["updated_at"]   = Time.now.to_f
            valid_non_users.push(non_user_record)

        end
      end
      if (!valid_non_users.empty?)
        AwsDynamodb.save_all_records("non_users",valid_non_users)
      end
    end
  end
   # gets array of phone_numbers and return hash of AwsUser's by phone_number (if on the User table)
  def self.get_users_by_phone(phone_numbers)
    users = Hash.new
     puts "PHONE NUMBERS #{phone_numbers}"
    if (!phone_numbers.nil? && !phone_numbers.empty?)
      users_hash = AwsDynamodb.get_hash_records_by_attribute("users",phone_numbers,"phone_number")

      users_hash.each do |user_phone,user_record|
        puts "USERS HASH #{user_record}"
        if (!user_record.nil? && !user_record.empty?)
          user = AwsUser.new
          user.internal_new_from_message(user_record)
          users[user.phone_number] = user
        end

      end
    end

    return users
  end

  # an attendee ,must have properties
  def valid_attendee
    #puts "USER DEVICE TOKENS #{@device_tokens}"
    return (!@phone_number.nil? && !@phone_number.empty?)
    # && !@first_name.nil? && !@first_name.empty? && !@last_name.nil? && !@last_name.empty?)
  end
  # a user ,must have properties
  def valid_user
    #puts "VALID USER - USER DEVICE TOKENS #{@device_tokens} #{@first_name} #{@phone_number} #{@last_name} "
    return (!@phone_number.nil? && !@phone_number.empty? && !@first_name.nil? && !@first_name.empty? && !@last_name.nil? && !@last_name.empty? && !@device_tokens.nil? && !@device_tokens.empty?)

  end
  def valid_non_user
    #puts "VALID USER - USER DEVICE TOKENS #{@device_tokens} #{@first_name} #{@phone_number} #{@last_name} "
    return (!@phone_number.nil? && !@phone_number.empty? && !@first_name.nil? && !@first_name.empty? && !@last_name.nil? && !@last_name.empty? && (@device_tokens.nil? || @device_tokens.empty?))

  end
end