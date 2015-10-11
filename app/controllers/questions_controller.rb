class QuestionsController < ApplicationController

  before_action :find_question, only: [:show, :vote]

  def index
    #todo: show how many? lots of logic to write in model for this action
  end

  def show
    render json: @question, status: 200
  end

  def create
    @question = Question.new
    @question.ask(question_create_params)
  end

  def vote
    if params[:vote] == 'yes'
      render json: { success: @questions.yes }, status:200
    elsif params[:vote] == 'no'
      render json: { success: @questions.no }, status:200
    else
      render json: { success: 'Invalid vote option #{params[:vote]}' }, status:400
    end
  end

  private
  def find_question
    @question = Question.find(params[:id])
  end

  def question_create_params
    params.require(:question).permit(
        :text,
        :image
    )
  end
end
