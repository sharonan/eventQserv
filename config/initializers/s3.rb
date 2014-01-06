#class S3
#
#  #def self.new()
#    #options = {}
#
#    $s3 = AWS::S3.new(
#        :access_key_id => 'AKIAJ5H7P7PQYCDLJKYQ',
#        :secret_access_key => '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',
#        :region => 'us-west-2',
#    )
#    $env =   (Rails.env.production?)? "prod" : "dev"
#
#    #bucket = $s3.buckets[bucket_name]
#    #$s3.buckets.enable_logging_for(bucket_name)
#    #$s3.buckets[bucket_name]
#  #end
#  def self.log_to_bucket(bucket_name,folder,file_name,text)
#    #text = 'Hello World!'
#    #file_name = 'hello5'
#    #$s3.buckets[bucket_name].objects.with_prefix("new-event/")[file_name].write('hello there')
#    puts " BUCKET #{$env}-#{bucket_name}/#{folder}"
#    puts "FILE #{file_name}"
#    puts "TEXT #{text}"
#    $s3.buckets["#{$env}-#{bucket_name}/#{folder}"].objects[file_name].write(text,:content_type=> 'text/plain')
#  end
#  def self.upload_file_to_bucket(file_name, bucket_name)
#    file_name ='dev-users-profile-pictures'
#    bucket = $s3.buckets[file_name]
#
#
#    file_name =  '/Users/sharonnachum/Downloads/1003456_10100284367427194_197071062_n.jpg'
#    bucket_name =  "#{$env}-users-profile-pictures"
#    #bucket.objects.each do |obj|
#    #  puts obj.key
#    #
#    #end
#    key = File.basename(file_name)
#    $s3.buckets[bucket_name].objects[key].write(:file => file_name)
#    #$s3.buckets[bucket_name].objects[key].write('data')
#
#  end
#end