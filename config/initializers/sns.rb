#class Sns
#
#  #$sns
#  #def self.new()
#  #  #options = {}
#
#    $sns = AWS::SNS.new(
#        :access_key_id => 'AKIAJ5H7P7PQYCDLJKYQ',
#        :secret_access_key => '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',
#        :region => 'us-west-2', :create_topic => true, :delete_topic => false, :create_subscription => true)
#  #end
#    $env =   (Rails.env.production?)? "prod" : "dev"
#
#    $platform_application_arn =   (Rails.env.production?)? "arn:aws:sns:us-west-2:336183161136:app/APNS/CalEnterprise" : "arn:aws:sns:us-west-2:336183161136:app/APNS_SANDBOX/ClowderPush"
#
#    def self.enable_user_push_notification(device_token, user_phone_number)
#    client = $sns.client
#    puts "DEVICE TOKEN #{device_token}"
#    platform_attributes =  client.list_endpoints_by_platform_application({:platform_application_arn =>$platform_application_arn
#                                                                         })
#    endpoint_user_arn = ""
#    founded = false
#    puts " ATTRIBUTES ========= #{platform_attributes.data[:endpoints]}"
#    #if (endpoint_arns.nil? || endpoint_arns.data.nil? || endpoint_arns.data[:endpoints].nil? || endpoint_arns.data[:endpoints].empty?)
#    platform_attributes.data[:endpoints].each do|endpoint_hash|
#      if (!endpoint_hash.nil?)
#        puts "HASH #{endpoint_hash}"
#        puts "FIND??? #{endpoint_hash[:attributes]["Token"]}"
#        if (endpoint_hash[:attributes]["Token"] == device_token)
#          puts "FOUND #{endpoint_hash[:attributes]["Token"]}"
#          endpoint_hash[:attributes]["CustomUserData"] =  user_phone_number
#          founded = true
#          endpoint_user_arn = endpoint_hash[:endpoint_arn]
#          client.set_endpoint_attributes( {:endpoint_arn=> endpoint_hash[:endpoint_arn],:attributes=>{"Enabled"=>"true", "CustomUserData"=>user_phone_number, "Token"=>device_token} })
#          puts "ARN #{endpoint_hash[:endpoint_arn]}"
#        end
#      end
#    end
#    if (!founded)
#      puts "NOT FOUNDED"
#      endpoint_arn =  client.create_platform_endpoint(    {:platform_application_arn =>$platform_application_arn,
#                                                           :attributes=>{"Enabled"=>"true", "CustomUserData"=>user_phone_number, "Token"=>device_token},
#                                                           :token =>device_token,
#                                                           :custom_user_data => user_phone_number}
#
#      )
#      endpoint_user_arn =    endpoint_arn.data[:endpoint_arn]
#    end
#
#    #else
#    #  puts "USER ALREADY REGISTERED FOR PUSH WITH CURRENT DEVICE"
#    #  endpoint_arn =  endpoint_arns.data[:endpoints][]
#    #end
#
#    puts "THE ARN ======= #{endpoint_user_arn}"
#    return    endpoint_user_arn
#  end
#  def self.send_push_notification(endpoint,hidden_message,alert)
#    AwsS3.new
#
#    puts "ARN TO PUBLISH #{endpoint}"
#    #client = AWS::SNS::Client.new(
#    #:access_key_id => 'AKIAJ5H7P7PQYCDLJKYQ',
#    #    :secret_access_key => '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',
#    #    :region => 'us-west-2', :create_topic => true, :delete_topic => false, :create_subscription => true)
#    client = $sns.client
#
#    #message_in ={:default => message,:APNS_SANDBOX=>{ :aps => { :alert => alert, :badge => 9, :sound => 'default'}}}
#    ##alert = ""
#    #if (alert.empty?)
#    #  aps_sandbox_json = ""
#    #else
#    aps_sandbox_json =  {:aps => { :alert => alert,:badge => 1, :default => hidden_message}}.to_json
#    #aps_sandbox_json =  {:aps => { :alert => alert,:badge => 1, :sound =>'default' ,:default => message}}.to_json
#
#    #end
#    #if (aps_sandbox_json.empty?)
#    #  message_in =  { :default => alert}.to_json
#    #else
#    #  message_in ={ :default => alert,:APNS_SANDBOX =>aps_sandbox_json}.to_json
#    #end
#
#
#    message_in ={ :default => alert,:APNS_SANDBOX =>aps_sandbox_json}.to_json
#    #message_in = { :default => message,:APNS_SANDBOX =>}.to_json
#    #puts client.list_platform_applications()
#    puts "MESSAGE IN #{message_in}"
#    #message_in = '{"default":"This is the default Message","APNS_SANDBOX":"{ \"aps\" : { \"alert\" : \"You have got email.\", \"badge\" : 9,\"sound\" :\"default\"}}"}'
#
#    publish =    {:message => message_in, :target_arn => endpoint, :message_structure => 'json'}
#
#    puts "PUBLISH #{publish}"
#    sharon_token = 'c68d895e5c3abed459586c448d6786de3d3becfb720aebd35736024d4170833b'
#    begin
#      application_endpoints = client.list_endpoints_by_platform_application(:platform_application_arn =>$platform_application_arn  )
#      hashed_application_endpoints =     application_endpoints.data
#      # ARRAY OF HASHES
#      endpoints_ary = (hashed_application_endpoints[:endpoints])? hashed_application_endpoints[:endpoints] :Array.new
#
#      puts  "ATTRIBUTES hashed #{hashed_application_endpoints}"
#
#      puts  "END POINTS ARRAY #{endpoints_ary}"
#
#
#
#
#      client.publish publish
#    rescue  Exception => e
#      puts "EXCEPTION IN ENDPOINT SNS ...."
#      if (!hidden_message.nil? && !endpoint.nil? && !alert.nil?)
#        AwsS3.log_to_bucket('event-queue-logger','sns_exception',"#{Time.now.to_s}","Message #{hidden_message} to Endpoint #{endpoint} with the alert #{alert} wasn't sent #{e.message}")
#      end
#    end
#
#
#  end
#  # creates a topic and add sqs subscriber by sqs object
#  def self.create_topic(topicName)
#    topic = $sns.topics.create(topicName)
#    return  topic
#
#
#
#  end
#  def self.get_topic_by_name(topic_name)
#    return $sns.topics[topic_name]
#  end
#  def self.set_display_name(topic,name)
#    #name = "Hello sharona #{$i} message "
#    topic.display_name = name
#  end
#  def self.publish_topic(topic)
#    #topic.display_name('Hello sharona'+$i+' message ')
#    topic.publish(topic.display_name)
#  end
#  # subscribe to sns by arn string
#  #def self.add_subscribers(topicName,subscriber_arn)
#  #
#  #end
#  #
#  #subscribe to sns by object (sqs)
#  def self.add_subscribers(topic,subscriber_object)
#
#    #topic_subscriptions = topic.subscriptions
#    # puts "SUBSCRIBORS ==== #{topic_subscriptions}"
#    if (!topic.nil?)
#      #  #subscribed_already = topic_subscriptions[](subscriber_object.arn)
#      #  topic_in = false
#      #  topic_subscriptions.each do |s| topic_in = s.arn == subscriber_object.arn   end
#      #
#      #  #puts "SUBSCRIBORS AFTER ==== #{topic_subscriptions}"
#      #  if (!topic_in)
#      #    topic.subscribe( subscriber_object,   :update_policy => true)
#      #  end
#      #else
#      subscription = topic.subscribe(subscriber_object,   :update_policy => true)
#      #puts " SUBSCRIPTION #{subscription.confirmation_authenticated?}"
#      while (!subscription.nil? && !subscription.confirmation_authenticated?)
#        sleep(5)
#
#      end
#      #return  subscription
#      #subscription.confirm_subscription
#    end
#    #
#
#
#
#    #topic.subscribe( '1-310-227-5317')
#    #topic.subscribe( subscriber_object.arn,{ :protocol => 'sqs', :endpoint => subscriber_object.arn } )
#  end
#
#  def self.publish_to_topic_by_name(topic_name,message)
#    topic = $sns.topics.create(topic_name)
#    #puts "PUBLISH FIRST NEW TOPIC #{message} TO #{topic_name}"
#    #topic.display_name = message["uid"]
#    topic.publish(message)
#    puts "PUBLISHED...."
#  end
#end