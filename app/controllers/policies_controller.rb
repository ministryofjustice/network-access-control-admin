class PoliciesController < ApplicationController
  before_action :set_policy, only: %i[show edit update destroy]
  before_action :set_crumbs, only: %i[index new show edit destroy]

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

  def show; end

  def destroy
    authorize! :destroy, @policy
    if confirmed?
      if @policy.destroy
        redirect_to policies_path, notice: "Successfully deleted policy. "
      else
        redirect_to policy_path(@policy), error: "Failed to delete the policy"
      end
    else
      render "policies/destroy"
    end
  end

  def edit
    authorize! :update, @policy
  end

  def update
    authorize! :update, @policy
    @policy.assign_attributes(policy_params)

    if @policy.save
      redirect_to policy_path(@policy), notice: "Successfully updated policy. "
    else
      render :edit
    end
  end

private

  def policy_params
    params.require(:policy).permit(:name, :description, :fallback)
  end

  def policy_id
    params.fetch(:id)
  end

  def set_policy
    @policy = Policy.find(policy_id)
  end

  def set_crumbs
    @navigation_crumbs = [["Home", root_path], ["Policies", policies_path]]
  end
end
