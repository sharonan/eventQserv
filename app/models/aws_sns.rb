require 'json'
require 'aws-sdk'
class AwsSns

  def self.send_all(alert)
    AwsS3.new

    client = $sns.client
    subscription = $sns.subscriptions
     #alert =  "We've updated! Go to http://clowder.me to download the latest version with new features like Nudge and plenty of bug fixes."
    aps_sandbox_json =   {:aps => { :alert => alert,:badge => 1,  :sound => 'default'}}.to_json

    puts "APNS ENV #{$env} == #{$env == "prod"} "

    message_in = ( $env ==  "prod")?{ :default => alert,:APNS =>aps_sandbox_json}.to_json: { :default => alert,:APNS_SANDBOX =>aps_sandbox_json}.to_json
    #message_in =  { :default => alert,:APNS =>aps_sandbox_json}.to_json

    puts "MESSAGE IN #{message_in}"



    begin
      next_token = ""
      endpoints_ary = Array.new

          begin
            application_endpoints =   get_client_endpoints(next_token)

            next_token = application_endpoints["next_token"]
            if (!application_endpoints["endpoints"].nil? && !application_endpoints["endpoints"].empty?)
              endpoints_ary.concat(application_endpoints["endpoints"])
            end

      end while !next_token.nil? && !next_token.empty?

      puts  "COUNT #{endpoints_ary.count} "

      endpoints = Array.new

      endpoints_ary.each do |client_arn|
        if (client_arn[:attributes]["Enabled"] == 'true')
          endpoints.push(client_arn[:endpoint_arn])
        else
          if (re_enable_user_push_notification(client_arn[:endpoint_arn]) )
            endpoints.push(client_arn[:endpoint_arn])
          end
        end

      end
      puts  "count #{endpoints.count }"
      endpoints.each do |endpoint|
        #if (endpoint == 'arn:aws:sns:us-west-2:336183161136:endpoint/APNS/CalEnterprise/9b05ca50-1b33-32b0-a76d-ba7b0a143b1d')

          begin
          publish =    {:message => message_in, :target_arn => endpoint, :message_structure => 'json'}
          puts "PUBLISH #{publish}"
          client.publish publish
          rescue  Exception => e
            puts "EXCEPTION IN ENDPOINT SNS ....#{e.message}"
            end
            #end

      end

    rescue  Exception => e
      puts "EXCEPTION IN ENDPOINT SNS ...."
      if ( !alert.nil?)
        raise "Message to Endpoint with the alert #{alert} wasn't sent #{e.message}"
      end
    end

  end
  def self.get_client_endpoints(next_token)
    client = $sns.client
    endpoints_hash = Hash.new

    endpoints = Array.new

    application_endpoints = (!next_token.nil? && !next_token.empty? )?client.list_endpoints_by_platform_application(:platform_application_arn =>$platform_application_arn, :next_token => next_token  ):client.list_endpoints_by_platform_application(:platform_application_arn =>$platform_application_arn)

    hashed_application_endpoints =     application_endpoints.data

    endpoints = (hashed_application_endpoints[:endpoints])? hashed_application_endpoints[:endpoints] :Array.new

    endpoints_hash["next_token"] = hashed_application_endpoints[:next_token]
    endpoints_hash["endpoints"]  = endpoints


    return endpoints_hash
  end
  def publish_all(client,publish)
    begin
       client publish
    rescue  Exception => e
      raise "EXCEPTION IN ENDPOINT SNS ....#{e.message}"
    end

  end
  def self.re_enable_user_push_notification(endpoint_arn)
    enabled = false
    #AwsS3.new
    puts "RE ENABLE ??? #{enabled}"
    if (!endpoint_arn.nil?)
    client = $sns.client
    begin
    client.set_endpoint_attributes( {:endpoint_arn=> endpoint_arn,:attributes=>{"Enabled"=>"true"} })
      enabled = check_endpoint_enable(endpoint_arn)
    rescue    Exception => e
      raise "Endpoint to ARN #{endpoint_arn} couldnt enable #{e.message}"

    end
    end
    puts "RE ENABLE ??? #{enabled}"
    return enabled
  end

  def self.enable_user_push_notification(device_token, user_phone_number)
    client = $sns.client
    puts "DEVICE TOKEN #{device_token}"
    platform_attributes =  client.list_endpoints_by_platform_application({:platform_application_arn =>$platform_application_arn
                                                                         })
    endpoint_user_arn = ""
    founded = false
    puts " ATTRIBUTES ========= #{platform_attributes.data[:endpoints]}"

    platform_attributes.data[:endpoints].each do|endpoint_hash|
      if (!endpoint_hash.nil?)
        puts "HASH #{endpoint_hash}"
        puts "FIND??? #{endpoint_hash[:attributes]["Token"]}"
        if (endpoint_hash[:attributes]["Token"] == device_token)
          puts "FOUND #{endpoint_hash[:attributes]["Token"]}"
          endpoint_hash[:attributes]["CustomUserData"] =  user_phone_number
          founded = true
          endpoint_user_arn = endpoint_hash[:endpoint_arn]
          client.set_endpoint_attributes( {:endpoint_arn=> endpoint_hash[:endpoint_arn],:attributes=>{"Enabled"=>"true", "CustomUserData"=>user_phone_number, "Token"=>device_token} })
          puts "ARN #{endpoint_hash[:endpoint_arn]}"
        end
      end
    end
    if (!founded)
      puts "NOT FOUNDED"
      endpoint_arn =  client.create_platform_endpoint(    {:platform_application_arn =>$platform_application_arn,
                                                           :attributes=>{"Enabled"=>"true", "CustomUserData"=>user_phone_number, "Token"=>device_token},
                                                           :token =>device_token,
                                                           :custom_user_data => user_phone_number}

      )
      endpoint_user_arn =    endpoint_arn.data[:endpoint_arn]
    end


    #puts "THE ARN ======= #{endpoint_user_arn}"
    return    endpoint_user_arn
  end
  def self.check_endpoint_enable(endpoint_arn)
    enable = false
    #AwsS3.new
    if (!endpoint_arn.nil? && !endpoint_arn.empty?)
      client = $sns.client
      begin
      endpoint_attr = client.get_endpoint_attributes({:endpoint_arn => endpoint_arn})
      #puts "ENDPOINT ATTR ,ENABLE = = #{endpoint_attr[:attributes]["Enabled"]}"
      enable =  endpoint_attr[:attributes]["Enabled"] == 'true'
      rescue  Exception => e
        puts "Exception  enabling #{endpoint_arn} === #{e.message}"
        raise "Exception  enabling #{endpoint_arn} === #{e.message}"

      end


    end

    return enable
  end
  def self.send_push_notification(endpoint,hidden_message,alert,sound)
    #AwsS3.new
    client = $sns.client

    enabled = false
    if (!check_endpoint_enable(endpoint))

      enabled = re_enable_user_push_notification(endpoint)
    else
      enabled = true
    end

    if (enabled)
      puts "ARN TO PUBLISH #{endpoint}"
      alert_sound = (sound.nil? || sound.empty?)? 'default' : sound
      puts "SOUND EMPTY? #{alert_sound} "

      aps_sandbox_json =  (alert_sound=='none')?  {:aps => { :alert => alert,:badge => 1, :default => hidden_message}}.to_json : {:aps => { :alert => alert,:badge => 1, :default => hidden_message, :sound => alert_sound}}.to_json

      puts "APNS ENV #{$env} == #{$env == "prod"} "

      message_in = ( $env ==  "prod")?{ :default => alert,:APNS =>aps_sandbox_json}.to_json: { :default => alert,:APNS_SANDBOX =>aps_sandbox_json}.to_json
      #message_in =  { :default => alert,:APNS_SANDBOX =>aps_sandbox_json}.to_json

      puts "MESSAGE IN #{message_in}"

      publish =    {:message => message_in, :target_arn => endpoint, :message_structure => 'json'}

      puts "PUBLISH #{publish}"

      begin

        client.publish publish
      rescue  Exception => e
        puts "EXCEPTION IN ENDPOINT SNS ...."
        if (!hidden_message.nil? && !endpoint.nil? && !alert.nil?)
          raise "Message #{hidden_message} to Endpoint #{endpoint} with the alert #{alert} wasn't sent #{e.message}"
        end
      end

    else
      raise "Endpoint #{endpoint} cant be enable"

    end


  end
  # creates a topic and add sqs subscriber by sqs object
  def self.create_topic(topicName)
    topic = $sns.topics.create(topicName)
    return  topic



  end
  def self.get_topic_by_name(topic_name)
    return $sns.topics[topic_name]
  end
  def self.set_display_name(topic,name)

    topic.display_name = name
  end
  def self.publish_topic(topic)

    topic.publish(topic.display_name)
  end

  def self.add_subscribers(topic,subscriber_object)
    if (!topic.nil?)

      subscription = topic.subscribe(subscriber_object,   :update_policy => true)

      while (!subscription.nil? && !subscription.confirmation_authenticated?)
        sleep(5)

      end

    end

  end

  def self.publish_to_topic_by_name(topic_name,message)
    topic = $sns.topics.create(topic_name)
    topic.publish(message)
    puts "PUBLISHED...."
  end
  end
