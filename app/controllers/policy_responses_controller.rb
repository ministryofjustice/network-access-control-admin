class PolicyResponsesController < ApplicationController
  before_action :set_policy, only: %i[new create destroy edit update]
  before_action :set_crumbs, only: %i[new edit destroy]
  before_action :redirect_to_policies_path, only: :index

  def new
    @response = PolicyResponse.new
  end

  def create
    @response = PolicyResponse.new(response_params.merge(policy_id: @policy.id))
    authorize! :create, @response

    if @response.save
      redirect_to policy_path(@policy), notice: "Successfully created response."
    else
      render :new
    end
  end

  def destroy
    @response = PolicyResponse.find(params.fetch(:id))

    authorize! :destroy, @response
    if confirmed?
      if @response.destroy
        redirect_to policy_path(@policy), notice: "Successfully deleted response. "
      else
        redirect_to policy_path(@policy), error: "Failed to delete the response. "
      end
    else
      render "policy_responses/destroy"
    end
  end

  def edit
    @response = PolicyResponse.find(params.fetch(:id))
    authorize! :update, @response
  end

  def update
    @response = PolicyResponse.find(params.fetch(:id))
    authorize! :update, @response

    @response.assign_attributes(response_params)

    if @response.save
      redirect_to policy_path(@policy), notice: "Successfully updated response. "
    else
      render :edit
    end
  end

  def index; end

private

  def policy_id
    params.fetch(:policy_id)
  end

  def response_params
    response_parameters = params.require(:policy_response).permit(:response_attribute, :value)

    if params[:policy_response][:'response-attribute'] == "custom"
      response_parameters[:response_attribute] = params[:policy_response][:custom_response_attribute]
    end

    response_parameters
  end

  def set_policy
    @policy = Policy.find(policy_id)
  end

  def set_crumbs
    @navigation_crumbs << ["Policies", policies_path]
  end

  def redirect_to_policies_path
    redirect_to policies_path
  end
end
