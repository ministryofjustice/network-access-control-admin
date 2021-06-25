class MonitoringController < ApplicationController
  skip_before_action :authenticate_user!, only: [:healthcheck]

  def healthcheck
    render body: "Healthy"
  end
end
