class QuestionsController < ApplicationController
  before_action :check_login, only: [:vote, :create]

  before_action :find_question, only: [:show, :vote]

  def index
    #todo: show how many? lots of logic to write in model for this action. For now, ranked based on activity
    render json: @questions, status: 200
  end

  def show
    render json: @question, status: 200
  end

  def friends_top
    #todo: this calculation should happen when user logs in. Use resque to run in bg
  end

  def create
    @question = Question.new
    @question.ask(question_create_params)
  end

  def vote
    if params[:vote] == 'yes'
      @current_user.cast_vote(@question.id, 1)
      render json: { success: @question.yes }, status:200
    elsif params[:vote] == 'no'
      @current_user.cast_vote(@question.id, 0)
      render json: { success: @question.no }, status:200
    else
      render json: { success: 'Invalid vote option #{params[:vote]}' }, status:400
    end
  end

  private
  def find_question
    @question = Question.find(params[:id])
  end

  def find_questions
    page = headers[:page].nil? ? 0 : headers[:page].to_i
    start = (page - 1) * 10
    stop = page * 10
    @questions = Question.top_list(start, stop)
  end

  def question_create_params
    params.require(:question).permit(
        :text,
        # :image
    )
  end
end
