class ResponsesController < ApplicationController
  before_action :set_policy, only: %i[new create destroy edit update]

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

  def destroy
    @response = Response.find(params.fetch(:id))

    authorize! :destroy, @response
    if confirmed?
      if @response.destroy
        redirect_to policy_path(@policy), notice: "Successfully deleted response. "
      else
        redirect_to policy_path(@policy), error: "Failed to delete the response. "
      end
    else
      render "responses/destroy"
    end
  end

  def edit
    @response = Response.find(params.fetch(:id))
    authorize! :update, @response
  end

  def update
    @response = Response.find(params.fetch(:id))
    authorize! :update, @response

    @response.assign_attributes(response_params)

    if @response.save
      redirect_to policy_path(@policy), notice: "Successfully updated response. "
    else
      render :edit
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

  def confirmed?
    params.fetch(:confirm, false)
  end
end
