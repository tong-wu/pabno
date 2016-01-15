class VoteService
  def initialize(options, selected, question_id, user_id)
    @options = options
    @selected = selected
    @question = Question.find(question_id)
    @user = User.find(user_id)
  end

  def vote
    begin
      if check_if_option_valid
        @question.vote(user_id, selected)
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
      @user.check_if_can_vote
    end
  end
end