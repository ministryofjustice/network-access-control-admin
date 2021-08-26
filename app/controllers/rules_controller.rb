class RulesController < ApplicationController
  before_action :set_policy, only: %i[new create destroy edit update]
  before_action :set_crumbs, only: %i[new edit destroy]
  before_action :redirect_to_policies_path

  def new
    @rule = Rule.new
  end

  def create
    @rule = Rule.new(rule_params.merge(policy_id: @policy.id))
    authorize! :create, @rule

    if @rule.save
      redirect_to policy_path(@policy), notice: "Successfully created rule."
    else
      render :new
    end
  end

  def destroy
    @rule = Rule.find(params.fetch(:id))

    authorize! :destroy, @rule
    if confirmed?
      if @rule.destroy
        redirect_to policy_path(@policy), notice: "Successfully deleted rule. "
      else
        redirect_to policy_path(@policy), error: "Failed to delete the rule. "
      end
    else
      render "rules/destroy"
    end
  end

  def edit
    @rule = Rule.find(params.fetch(:id))
    authorize! :update, @rule
  end

  def update
    @rule = Rule.find(params.fetch(:id))
    authorize! :update, @rule

    @rule.assign_attributes(rule_params)

    if @rule.save
      redirect_to policy_path(@policy), notice: "Successfully updated rule. "
    else
      render :edit
    end
  end

private

  def policy_id
    params.fetch(:policy_id)
  end

  def set_policy
    @policy = Policy.find(policy_id)
  end

  def rule_params
    params.require(:rule).permit(:request_attribute, :value, :operator)
  end

  def redirect_to_policies_path
    redirect_to policies_path if @policy.fallback?
  end

  def set_crumbs
    @navigation_crumbs = [["Home", root_path], ["Policies", policies_path]]
  end
end
