if Rails.env.production?
  #production configs
  Aws.config.update(
      region:      ENV['aws_region'],
      credentials: Aws::Credentials.new(ENV['aws_access_key_id'], ENV['aws_secret_access_key'])
  )
  # AWS_S3_BUCKET_IMGS   = Aws::S3::Bucket.new('nosey-images', {client: client})
  AWS_DYNAMO_VOTES_BY_USER_TBL = 'NOSEY-DEV-votes_by_user'
  AWS_DYNAMO_VOTES_BY_QUESTION_TBL = 'NOSEY-LIVE-votes-by-question'

else
  Aws.config.update(
      region:      ENV['aws_region'],
      credentials: Aws::Credentials.new(ENV['aws_access_key_id_dev'], ENV['aws_secret_access_key_dev'])
  )
  # AWS_S3_BUCKET_IMGS   = Aws::S3::Bucket.new('nosey-images-dev', {client: client})
  AWS_DYNAMO_VOTES_BY_USER_TBL = 'NOSEY-DEV-votes_by_user'
  AWS_DYNAMO_VOTES_BY_QUESTION_TBL = 'NOSEY-DEV-votes-by-question'
end

AWS_DYNAMO = Aws::DynamoDB::Client.new
