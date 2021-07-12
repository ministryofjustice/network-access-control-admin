# frozen_string_literal: true

class AuditsController < ApplicationController
  def index
    @audits = Audit.order(created_at: "DESC").page params[:page]
  end

  def show
    @audit = Audit.find(params[:id])
  end
end
