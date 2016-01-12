module AwsHelper
  def aws_send_vote(user_id, vote_val, question_id)
    response = AWS_DYNAMO.batch_write_item({
                                    request_items:{
                                        AWS_DYNAMO_VOTES_BY_QUESTION_TBL => [
                                            {
                                                put_request: {
                                                    item: {
                                                        "question_id" => question_id,
                                                        "user_id" => user_id,
                                                        "voted" => vote_val.to_s,
                                                        "timestamp" => Time.now.to_i.to_s
                                                    }
                                                }
                                            }
                                        ],
                                        AWS_DYNAMO_VOTES_BY_USER_TBL => [
                                            {
                                                put_request: {
                                                    item: {
                                                        "user_id" => user_id,
                                                        "timestamp" => Time.now.to_i.to_s,
                                                        "question_id" => question_id,
                                                        "voted" => vote_val.to_s
                                                    }
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