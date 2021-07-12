class ResponsesController < ApplicationController
  before_action :set_policy, only: [:new, :create]

  def new
    @response = Response.new
  end

  def create
    @response = Response.new(response_params.merge(policy_id: @policy.id))
    authorize! :create, @response

    if @response.save
      redirect_to policy_path(@policy), notice: "Successfully created response."
    else
      render :new
    end
  end

  private

  def policy_id
    params.fetch(:policy_id)
  end

  def response_params
    params.require(:response).permit(:response_attribute, :value)
  end

  def set_policy
    @policy = Policy.find(policy_id)
  end
end
