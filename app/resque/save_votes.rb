class SaveVotes
  @queue = :votes_q

  def self.perform(question_id)
    q = Question.find(question_id)
    q.options[:yes] += REDIS_VOTES.get("YES:#{question_id}").to_i
    q.options[:no] += REDIS_VOTES.get("NO:#{question_id}").to_i
    if !@REDIS_VOTES.get("VOTES:#{question_id}").nil?
      num_votes = REDIS_VOTES.get("VOTES:#{question_id}").to_i
      q.ranking = q.ranking.to_i + (num_votes * 10)
      #todo: check toplist
    end
    q.save
    REDIS_VOTES.del("YES:#{question_id}")
    REDIS_VOTES.del("NO:#{question_id}")
    REDIS_VOTES.del("VOTES:#{question_id}")
  end
end