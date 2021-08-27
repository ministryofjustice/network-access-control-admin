class AuditsController < ApplicationController
  before_action :set_crumbs, only: %i[index show]

  def index
    @audits = Audit.order(created_at: "DESC").page params[:page]
  end

  def show
    @audit = Audit.find(params[:id])
  end

private

  def set_crumbs
    @navigation_crumbs << ["Audit Log", audits_path]
  end
end
