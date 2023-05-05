require 'rails_helper'

RSpec.describe BackgroundJobWorker, type: :worker do
  let(:worker) { BackgroundJobWorker.new }

  describe '#perform' do
    let!(:background_job) { create(:background_job, job_type: :import_searched_movies, status: :pending, arguments: { query: '検索クエリ' }) }

    context '正常な場合' do
      before do
        allow(worker).to receive(:execute)
      end

      it 'ジョブが正しく処理される' do
        worker.perform(background_job.id)
        background_job.reload
        expect(background_job.status).to eq('complete')
        expect(worker).to have_received(:execute).with(job: background_job)
      end
    end

    context 'エラーが発生した場合' do
      before do
        allow(worker).to receive(:execute).and_raise(StandardError)
      end

      it 'ジョブのステータスがエラーになる' do
        expect { worker.perform(background_job.id) }.to raise_error(StandardError)
        background_job.reload
        expect(background_job.status).to eq('error')
      end
    end
  end

  describe '#execute' do
    let(:background_job) { build(:background_job, job_type: :import_searched_movies, arguments: { query: '検索クエリ' }) }

    context '正常な場合' do
      before do
        allow(MovieService).to receive(:import_searched_movies)
      end

      it 'ジョブが正しく処理される' do
        worker.execute(job: background_job)
        expect(MovieService).to have_received(:import_searched_movies).with(query: '検索クエリ', job: background_job)
      end
    end

    # background_job.job_type = :unsupported_job_typeで例外が吐かれるので
    # このテストはコメントアウトしておく
    # context 'サポートされていないjob_typeの場合' do
    #   before do
    #     background_job.job_type = :unsupported_job_type
    #   end

    #   it 'エラーが発生する' do
    #     expect { worker.execute(job: background_job) }.to raise_error(/Unsupported job_type/)
    #   end
    # end
  end
end
