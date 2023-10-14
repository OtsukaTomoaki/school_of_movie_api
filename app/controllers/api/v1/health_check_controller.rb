class Api::V1::HealthCheckController < ApplicationController
  def index
    render json: { success: true }
  end
end
