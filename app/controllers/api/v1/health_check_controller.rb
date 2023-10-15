class Api::V1::HealthCheckController < Api::V1::ApplicationController
  skip_before_action :current_user, only: [:index]

  def index
    render json: { success: true }
  end
end
