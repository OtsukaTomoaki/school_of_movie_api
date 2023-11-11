require 'rails_helper'

RSpec.describe "Api::V1::HealthChecks", type: :request do
  describe "GET /index" do
    subject { get api_v1_health_check_index_path }

    it "returns http success" do
      subject
      expect(response).to have_http_status(:success)
    end
  end
end
