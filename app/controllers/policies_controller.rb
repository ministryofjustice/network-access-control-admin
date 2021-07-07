class PoliciesController < ApplicationController
  before_action :set_policy, only: [:show]

  def new
    @policy = Policy.new
    authorize! :create, @policy
  end

  def create
    @policy = Policy.new(policy_params)
    authorize! :create, @policy

    if @policy.save
      redirect_to policy_path(@policy), notice: "Successfully created policy. "
    else
      render :new
    end
  end

  def index
    @policies = Policy.all
  end

  def show
  end

  private

  def policy_params
    params.require(:policy).permit(:name, :description)
  end

  def policy_id
    params.fetch(:id)
  end

  def set_policy
    @policy = Policy.find(policy_id)
  end
end
