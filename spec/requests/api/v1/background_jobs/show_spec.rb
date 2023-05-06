require 'rails_helper'

RSpec.describe "Api::V1::BackgroundJobs", type: :request do
  describe "GET /show" do
    let!(:background_job) { create(:background_job, job_type: BackgroundJob.job_types[:import_searched_movies], status: BackgroundJob.statuses[:pending]) }

    context '存在するジョブのIDが渡された場合' do
      before do
        get api_v1_background_job_path(background_job.id), params: params
      end

      let(:params) { nil }
      it '正常なレスポンスが返されること' do
        expect(response).to have_http_status(:ok)
      end

      it 'レスポンスボディが正しいこと' do
        json = JSON.parse(response.body)
        expect(json['id']).to eq background_job.id
        expect(json['job_type']).to eq background_job.job_type
        expect(json['status']).to eq background_job.status
        expect(json['progress']).to eq background_job.progress
        expect(json['total']).to eq background_job.total
        expect(json['created_at']).to eq background_job.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
        expect(json['finished_at']).to eq background_job.finished_at&.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
        expect(json['arguments']).to eq background_job.arguments
      end
    end

    context '存在しないジョブのIDが渡された場合' do
      it 'RecordNotFoundが発生すること' do
        expect {
          get api_v1_background_job_path('1234-5678-1234-5678')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
