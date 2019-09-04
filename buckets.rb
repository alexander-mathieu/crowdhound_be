require 'aws-sdk-s3'  # v2: require 'aws-sdk'

s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])

s3.buckets.limit(50).each do |b|
  puts "#{b.name}"
end