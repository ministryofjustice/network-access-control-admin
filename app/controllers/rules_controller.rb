class RulesController < ApplicationController
  before_action :set_policy, only: [:new, :create]

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
end
