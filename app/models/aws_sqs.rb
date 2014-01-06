require 'aws-sdk'

class AwsSqs


  # creates an sqs queue and set indefinite  long polling  process
  def self.create_sqs(sqs_name)
    puts "SQS NAME #{$env}_#{sqs_name} "
    queue = $sqs.queues.create("#{$env}_#{sqs_name}")

    return queue

  end
  def self.create_test_sqs(sqs_name)
    puts "SQS NAME #{sqs_name} "
    queue = $sqs.queues.create("#{sqs_name}")

    return queue

  end
  def self.push_test_message(queue_name,message_friend,options={})
    queue = $sqs.queues.create("#{queue_name}")
    queue.send_message(message_friend,options)
  end
  # long polling (wait_time_seconds == 10) indefinitely  for the first message
  # this method automatically deletes the message then the block exits normally.
  # Every message polled from the queue is processed by the   process_queue_msg method
  def self.long_polling_queue(queue)
    queue.poll(:initial_timeout => false,
               :wait_time_seconds => 10){|msg| process_queue_msg(msg)}
  end

  def self.process_queue_msg(msg)
    puts  msg
  end
  # @option options [Integer] :delay_seconds The number of seconds to
  #   delay the message. The message will become available for
  #   processing after the delay time has passed.
  #   If you don't specify a value, the default value for the
  #   queue applies.  Should be from 0 to 900 (15 mins).
  #
  def self.push_message(queue_name,message_friend,delay_seconds=0)
    options={}
    if (delay_seconds>0)
      options={:delay_seconds => delay_seconds}
    end
    puts "delayed message seconds #{delay_seconds}"
    queue = $sqs.queues.create("#{$env}_#{queue_name}")
    queue.send_message(message_friend,options)
  end

  def self.delete_message_by_messageId(queue_name,message_id)

    queue = $sqs.queues.create("#{$env}_#{queue_name}")
  end
 def self.health_check(queue_name,min_visible_messages)
   queue = AwsSqs.create_sqs(queue_name)

   return (min_visible_messages > queue.approximate_number_of_messages)
 end
  def self.health_test_check(queue_name,min_visible_messages)
    queue = AwsSqs.create_test_sqs(queue_name)

    return (min_visible_messages > queue.approximate_number_of_messages)
  end
  def self.add_permission(queue_name, publisher_arn)


    if (!queue_name.nil? && !publisher_arn.nil? && !$sqs_client.nil?)
      queue = $sqs.queues.create("#{$env}_#{queue_name}")
      attributes = {:id => queue.arn,

                    :Statement => [{
                                       #:Sid": "Sid" + new Date().getTime(),
                                       :Effect =>"Allow",
                                       :Principal => {
                                           :AWS => "*"
                                       },
                                       :Action =>"SQS:SendMessage",
                                       :Resource => queue.arn,
                                       :Condition => {
                                           :ArnEquals => {
                                               :SourceArn => publisher_arn
                                           }
                                       }
                                   }
                    ]
      }
      sqs_permissions = [{ :queue_url => queue.url ,
                       :label  =>   publisher_arn          ,
                       :aws_account_ids =>  $aws_account_ids  ,
                       :actions =>["sendMessage"]

                     }]
      #:queue_url => url,
      #att = {:queue_url => queue.url ,
      #       :attributes => attributes }
      #
      #
      ##policy = AWS::SQS::Policy.new( :access_key_id => 'AKIAJ5H7P7PQYCDLJKYQ',
      #                               :secret_access_key => '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',
      #                               :region => 'us-west-2')
      #policy.allow(
      #    :actions => ["SQS:SendMessage"],
      #    :resources => publisher_arn,
      #    :principals => :any
      #)
      #params = {:queue_url => queue.url ,
      #          :attributes => {:policy => policy}
      #         }
      #policy.
      #queue.policy=policy
      #puts "sharon"
      #client.set_queue_attributes(queue.url, "policy", policy.to_json)
      $sqs_client.add_permission(sqs_permissions)

    end
  end
end