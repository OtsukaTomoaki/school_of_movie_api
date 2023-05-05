require 'rails_helper'

RSpec.describe BackgroundJob, type: :model do
  # バリデーションのテスト
  describe 'バリデーション' do
    # 共通の条件をまとめる
    let(:background_job) { build(:background_job, job_type: :import_searched_movies, next_request_at: Time.current) }

    context 'job_typeとnext_request_atが存在する場合' do
      it '有効である' do
        expect(background_job).to be_valid
      end
    end

    context 'job_typeが存在しない場合' do
      it '無効である' do
        background_job.job_type = nil
        expect(background_job).not_to be_valid
      end
    end

    context 'next_request_atが存在しない場合' do
      it '無効である' do
        background_job.next_request_at = nil
        expect(background_job).not_to be_valid
      end
    end
  end

  # メソッドのテスト
  describe 'メソッド' do
    let(:background_job) { create(:background_job, job_type: :import_searched_movies, next_request_at: Time.current) }

    describe '.schedule_import_searched_movies' do
      let(:query) { '検索クエリ' }

      context "同じジョブが実行中でない場合" do
        it 'スケジュールされたジョブが作成される' do
          expect {
            BackgroundJob.schedule_import_searched_movies(query: query)
          }.to change { BackgroundJob.count }.by(1)
        end

        it '作成されたジョブのjob_typeがimport_searched_moviesである' do
          job = BackgroundJob.schedule_import_searched_movies(query: query)
          expect(job.job_type).to eq('import_searched_movies')
        end

        it '作成されたジョブのstatusがpendingである' do
          job = BackgroundJob.schedule_import_searched_movies(query: query)
          expect(job.status).to eq('pending')
        end

        it '作成されたジョブのnext_request_atが現在時刻である' do
          job = BackgroundJob.schedule_import_searched_movies(query: query)
          expect(job.next_request_at).to be_within(1.second).of(Time.current)
        end

        it '作成されたジョブのargumentsにqueryが含まれる' do
          job = BackgroundJob.schedule_import_searched_movies(query: query)
          expect(job.arguments['query']).to eq(query)
        end
      end

      context "同じジョブが実行中の場合" do
        before do
          create(:background_job,
            job_type: described_class.job_types[:import_searched_movies],
            status: described_class.statuses[:processing],
            arguments: { query: query })
        end

        it 'スケジュールされたジョブが作成されない' do
          expect {
            BackgroundJob.schedule_import_searched_movies(query: query)
          }.not_to change { BackgroundJob.count }
        end

        it '実行中のジョブが返される' do
          job = BackgroundJob.schedule_import_searched_movies(query: query)
          expect(job.status).to eq('processing')
        end
      end
    end

    describe '#enqueue' do
      it 'BackgroundJobWorkerにジョブが追加される' do
        expect(BackgroundJobWorker).to receive(:perform_at).with(background_job.next_request_at, background_job.id)
        background_job.enqueue
      end
    end
  end
end
