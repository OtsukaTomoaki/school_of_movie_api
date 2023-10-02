require 'rails_helper'

RSpec.describe "Api::V1::BackgroundJobs", type: :request do
  describe "GET /index" do
    let!(:job1) { create(:background_job, job_type: :import_searched_movies, status: :pending, created_at: 1.day.ago) }
    let!(:job2) { create(:background_job, job_type: :import_searched_movies, status: :processing, created_at: 2.days.ago) }
    let!(:job3) { create(:background_job, job_type: :import_searched_movies, status: :complete, created_at: 3.days.ago) }
    let!(:job4) { create(:background_job, job_type: :import_searched_movies, status: :error, created_at: 4.days.ago) }

    before do
      get api_v1_background_jobs_path, params: params
    end

    context 'statusとjob_typeを指定しない場合' do
      let(:params) { {} }

      it '全てのジョブが新しい順に返されること' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['background_jobs'].map { |j| j['id'] }).to eq [job1.id, job2.id, job3.id, job4.id]
      end
    end

    context 'statusを指定する場合' do
      let(:params) { { status: 'pending' } }

      it '指定されたstatusのジョブが新しい順に返されること' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['background_jobs'].map { |j| j['id'] }).to eq [job1.id]
      end
    end

    context 'job_typeを指定する場合' do
      let(:params) { { job_type: 'import_searched_movies' } }

      it '指定されたjob_typeのジョブが新しい順に返されること' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['background_jobs'].map { |j| j['id'] }).to eq [job1.id, job2.id, job3.id, job4.id]
      end
    end

    context 'statusとjob_typeを指定する場合' do
      let(:params) { { status: 'processing', job_type: 'import_searched_movies' } }

      it '指定されたstatusとjob_typeのジョブが新しい順に返されること' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['background_jobs'].map { |j| j['id'] }).to eq [job2.id]
      end
    end

    context 'ページネーションが適用される場合' do
      let(:params) { { page: 2, per_page: 2 } }
      it '指定されたページのジョブが返されること' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['background_jobs'].map { |j| j['id'] }).to eq [job3.id, job4.id]
      end
    end
  end
end
