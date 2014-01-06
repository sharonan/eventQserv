#require 'mail'
#require 'ri_cal'
#require 'rubygems'
#require 'json'
require 'aws-sdk'
#require 'active_support/core_ext'
#require 'right_aws'
#require 'digest/md5'
#require 'threadpool'
#require 'rufus-scheduler'
##require 'rack/google_analytics'
#require 'restclient'
#require 'json'
#require 'base64'
#require 'logger'

class AwsS3

  def self.log_to_bucket(bucket_name,folder,file_name,text)

    puts " BUCKET #{$env}-#{bucket_name}/#{folder}"
    puts "FILE #{file_name}"
    puts "TEXT #{text}"
    unless Rails.env.test?
      $s3.buckets["#{$env}-#{bucket_name}/#{folder}"].objects[file_name].write(text,:content_type=> 'text/plain')
    end
  end
  def self.upload_file_to_bucket(file_name, bucket_name)
    file_name ='dev-users-profile-pictures'
    bucket = $s3.buckets[file_name]


    file_name =  '/Users/sharonnachum/Downloads/1003456_10100284367427194_197071062_n.jpg'
    bucket_name =  "#{$env}-users-profile-pictures"

    key = File.basename(file_name)
    $s3.buckets[bucket_name].objects[key].write(:file => file_name)

  end
end