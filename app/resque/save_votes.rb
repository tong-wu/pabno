class SaveVotes
  @queue = :votes_q

  def self.perform(question_id)
    q = Question.find(question_id.to_i)
    q.options[:yes] += REDIS_VOTES.get("YES:#{question_id}").to_i
    q.options[:no] += REDIS_VOTES.get("NO:#{question_id}").to_i
    q.save
    REDIS_VOTES.del("YES:#{question_id}")
    REDIS_VOTES.del("NO:#{question_id}")
    REDIS_VOTES.del("VOTES:#{question_id}")
  end
end