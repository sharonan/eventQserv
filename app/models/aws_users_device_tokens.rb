class  AwsUsersDeviceTokens

  @device_token_arn
  @device_token
  @phone_number


  def new

  end
  def phone_number
    return (@phone_number.nil?)? "" : @phone_number
  end
  def device_token
    return (@device_token.nil?)?  "" : @device_token
  end
  def device_token_arn
    return (@device_token_arn.nil?)? "" : @device_token_arn
  end

  #  Gets Array of phone numbers
  # Return Array of aws_users_device_tokens (both users or non users objects)
  def self.get_users_device_tokens_from_aws(phone_numbers)
    users_device_tokens = Array.new
    phones_device_tokens = Array.new
    if (!phone_numbers.nil? && !phone_numbers.empty?)

      #get_all_hash_records_by_hash("users_device_tokens",[:phone_number, :string],[:device_token, :string],all_attendees_phone_numbers,"phone_number")
      all_users_device_tokens_aws_records = AwsDynamodb.get_all_range_records_by_hash("users_device_tokens",phone_numbers)
      puts "all_users_device_tokens_aws_records #{all_users_device_tokens_aws_records}"
      if (!all_users_device_tokens_aws_records.nil? && !all_users_device_tokens_aws_records.empty?)
        all_users_device_tokens_aws_records.each do |user_device_token_record|
        user_device_token = AwsUsersDeviceTokens.new
        user_device_token.setup_user_device_token_from_record(user_device_token_record)
        phones_device_tokens.push(user_device_token)
        end

      end
      users_device_tokens = setup_users_device_tokens(phone_numbers, phones_device_tokens)

    end
    return users_device_tokens
  end
  def setup_user_device_token_from_record(record)
    if (!record.nil? && !record.empty?)
      @phone_number = (record.has_key?("phone_number"))? record["phone_number"]:""
      @device_token = (record.has_key?("device_token"))? record["device_token"]:""
      @device_token_arn = (record.has_key?("device_token_arn"))? record["device_token_arn"]:""
    end
  end
  def get_record_from_user_device_token
    record = Hash.new

    record["phone_number"] = @phone_number
    record["device_token_arn"] = @device_token_arn
    record["device_token"] = @device_token

    return record
  end

  def self.save_users_device_tokens_to_db(users_device_tokens)
    if (!users_device_tokens.nil? && !device_token_arn.empty?)
      users_device_tokens_records = Array.new
      users_device_tokens.each do |user_device_token|
        if (user_device_token.valid_user_device_token)
          users_device_tokens_records.push(user_device_token.get_record_from_user_device_token)
        end
      end
      if (!users_device_tokens_records.nil? && !users_device_tokens_records.empty?)
        AwsDynamodb.save_all_records("users_device_tokens", users_device_tokens_records)
      end
    end

  end
  ## Gets Array of phone_numbers and Array of aws_users_device_tokens
  ## Return Array of aws_device_tokens from the phone_numbers array found among the aws_users_device_tokens
  ## and if not (non_user) a non_user device_token object (just phone_number)
  def self.setup_users_device_tokens(phone_numbers, users_device_tokens)
    puts "ALL PHONES #{phone_numbers} DEVICES FOUND = #{users_device_tokens}"
    phone_numbers_device_tokens = Array.new
    all_users_phones = phone_numbers.clone
    if (!all_users_phones.empty?)
    if (!users_device_tokens.nil? && !users_device_tokens.empty? && !all_users_phones.nil? && !all_users_phones.empty?)
      users_device_tokens.each do |user_device_token|

          if (user_device_token.valid_user_device_token && all_users_phones.include?(user_device_token.phone_number))
            phone_numbers_device_tokens.push(user_device_token)
            all_users_phones.delete(user_device_token.phone_number)
          end
      end
    end
        all_users_phones.each do|non_user_phone|
          non_user_device_token = AwsUsersDeviceTokens.new
          puts  "NON DEVICE #{non_user_phone}"
          non_user_device_token.setup_non_user_device_tokens(non_user_phone)

          phone_numbers_device_tokens.push(non_user_device_token)
        end






    end
    return phone_numbers_device_tokens
  end
  def setup_non_user_device_tokens(non_user_phone)

    if (!non_user_phone.nil? && !non_user_phone.empty?)
        @phone_number = non_user_phone
        @device_token_arn = ""
        @device_token = ""
    end
  end
  def valid_user_device_token
    return !@phone_number.empty? && !@device_token.empty? && !@device_token_arn.empty?
  end
  def non_user
    return  !@phone_number.empty? &&  (@device_token.empty?  || @device_token_arn.empty?)
  end

  end