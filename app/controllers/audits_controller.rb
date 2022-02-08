class AuditsController < ApplicationController
  before_action :set_crumbs, only: %i[index show]

  def index
    @auditable_types = Audit.distinct.pluck(:auditable_type)
    @auditable_actions = Audit.distinct.pluck(:action)
    @selected_type = params.dig(:q, :auditable_type)
    @selected_action = params.dig(:q, :action)

    @q = Audit
    @q = @q.where(auditable_type: @selected_type) unless @selected_type.nil?
    @q = @q.where(action: @selected_action) unless @selected_action.nil?
    @q = @q.ransack(params[:q])
    @q.sorts = params.dig(:q, :s) || "created_at desc"

    @audits = @q.result.page(params.dig(:q, :page))
  end

  def show
    @audit = Audit.find(params[:id])
  end

private

  def set_crumbs
    @navigation_crumbs << ["Audit Log", audits_path]
  end
end
