require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :request, authentication: :skip do
  describe 'GET #identity' do
    before do
      # 時間を固定
      Timecop.freeze(Time.zone.parse('2023-10-07 12:00:00'))
    end

    after do
      # 時間固定を解除
      Timecop.return
    end

    let!(:user) { authenticated_user }
    let!(:headers) {
      jwt = TokenService.send(:issue_token, user)
      { 'Authorization' => "Bearer #{jwt}" }
    }
    subject {
      get api_v1_sessions_identity_path, headers: headers
    }

    shared_context 'レスポンスの検証' do
      it 'ステータスの検証' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'ボディの検証' do
        subject
        body = JSON.parse(response.body)
        expect(body['user_name']).to eq(user.name)
        expect(body['expires_at']).to eq((DateTime.current + 1.days).to_i)
      end
    end

    it_behaves_like 'レスポンスの検証'
  end
end
