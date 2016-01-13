class VoteService
  def initialize(options, selected, question_id, user_id)
    @options = options
    @selected = selected
    @question_id = question_id
    @user_id = user_id
  end

  def vote
    begin
      if check_if_option_valid
        Question.find(question_id).vote(user_id, selected)
      else
        false
      end
    rescue
      false
    end
  end

  private

  attr_reader :options, :selected, :question_id, :user_id


  def check_if_option_valid
    if options.include? selected
      User.find(user_id).check_if_can_vote
    end
  end
end