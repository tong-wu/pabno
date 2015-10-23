module AwsHelper
  def aws_send_yes(user_id, vote_val)
    response = AWS_DYNAMO.batch_write_item({
                                    request_items:{
                                        "question_votes_data" => [
                                            {
                                                put_request: {
                                                    item: {
                                                        "question_id" => self.id,
                                                        "user_id" => user_id,
                                                        "voted" => vote_val.to_s,
                                                        "timestamp" => Time.now.to_i.to_s
                                                    }
                                                }
                                            }
                                        ],
                                        "user_votes_data" => [
                                            {
                                                put_request: {
                                                    item: aws_userdata(user_id)
                                                }
                                            }
                                        ]
                                    }
                                })
  end

  def aws_userdata(user_id)
    User.find(user_id).to_json
  end
end