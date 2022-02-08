class AuditsController < ApplicationController
  before_action :set_crumbs, only: %i[index show]

  def index
    @q = Audit.ransack(params[:q])
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
