
#AWS.config({ :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
#             :secret_access_key => ENV["AWS_SECRET_KEY"],
#           })
$aws_account_ids =    ["3361-8316-1136"]
$env =   (Rails.env.production?)? "prod" : "dev"
$platform_application_arn =   (Rails.env.production?)? "arn:aws:sns:us-west-2:336183161136:app/APNS/CalEnterprise" : "arn:aws:sns:us-west-2:336183161136:app/APNS_SANDBOX/CalDev"
#$platform_application_arn =   "arn:aws:sns:us-west-2:336183161136:app/APNS/CalEnterprise"
#$platform_application_arn =   "arn:aws:sns:us-west-2:336183161136:app/APNS_SANDBOX/CalDev"
puts "ENV #{$platform_application_arn}"
$sqs = AWS::SQS.new(
     #:access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    #:secret_access_key => ENV["AWS_SECRET_KEY"],
    :region => 'us-west-2')
$sqs_client = AWS::SQS::Client.new(
    #:access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    #                                 :secret_access_key => ENV["AWS_SECRET_KEY"],
                                    :region => 'us-west-2')
$s3 = AWS::S3.new(
    #:access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    #:secret_access_key => ENV["AWS_SECRET_KEY"],
    :region => 'us-west-2',
)
$sns = AWS::SNS.new(
    #:access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    #:secret_access_key => ENV["AWS_SECRET_KEY"],
    :region => 'us-west-2', :create_topic => true, :delete_topic => false, :create_subscription => true)

$dynamo_db = AWS::DynamoDB.new()
#:access_key_id => ENV["AWS_ACCESS_KEY_ID"],
#                                :secret_access_key => ENV["AWS_SECRET_KEY"])

#$env =   (Rails.env.production?)? "prod" : "dev"


$batch_write = AWS::DynamoDB::BatchWrite.new(
    #:access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    #                                          :secret_access_key => ENV["AWS_SECRET_KEY"],
                                             :region => 'us-west-2')
$batch_get = AWS::DynamoDB::BatchGet.new(
    #:access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    #                                      :secret_access_key => ENV["AWS_SECRET_KEY"],
                                         :region => 'us-west-2')
