# s3-settings for paperclip
# set credentials from environment
S3_SETTINGS = { :access_key_id     => ENV['AWS_ACCESS_KEY_ID'], 
                :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'], 
                :bucket            => ENV['S3_BUCKET_NAME'],
              }

# use s3 european server
Paperclip.interpolates(:s3_eu_url) { |attachment, style|
#  "#{attachment.s3_protocol}://s3-eu-west-1.amazonaws.com/#{attachment.bucket_name}/#{attachment.path(style)}"
  "#{attachment.s3_protocol}://s3.amazonaws.com/#{attachment.bucket_name}/#{attachment.path(style)}"
}

# module AWS
#   module S3
#     DEFAULT_HOST = "s3-eu-west-1.amazonaws.com"
#   end
# end