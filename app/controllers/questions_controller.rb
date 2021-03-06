class QuestionsController < ApplicationController
  before_action :check_login, only: [:vote, :create]

  before_action :find_question, only: [:show, :vote]
  before_action :find_questions, only: [:index]
  before_action :find_newest, only: [:newest]

  def index
    #todo: show how many? lots of logic to write in model for this action. For now, ranked based on activity
    render json: @questions, status: 200
  end

  def newest
    render json: @new_questions, status: 200
  end

  def show
    render json: @question, status: 200
  end

  def friends_top
    #todo: this calculation should happen when user logs in. Use resque to run in bg
  end

  def create
    @question = Question.new
    @question.ask(question_create_params, @current_user)
    render json: @question, status: 200
  end

  def vote
    cast_vote = VoteService.new([QuestionOption::YES, QuestionOption::NO], params[:vote], @question.id, @current_user.id).vote
    if cast_vote
      render json: { vote: params[:vote] }, status: 200
    else
      render json: { error: 'Vote was not recorded' }, status: 200
    end
  end

  private
  def find_question
    @question = Question.find(params[:id])
  end

  def find_questions
    page = headers[:page].nil? ? 1 : headers[:page].to_i
    @questions = Question.top_list(page)
  end

  def find_newest
    page = headers[:page].nil? ? 1 : headers[:page].to_i
    @new_questions = Question.new_list(page)
  end

  def question_create_params
    params.require(:question).permit(
        :text,
        # :image
    )
  end
end
