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
    describe '.schedule_import_searched_movies' do
      shared_context 'import_searched_moviesのジョブがスケジュールされる' do
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

      shared_context 'import_searched_moviesのジョブがスケジュールされず、すでに実行中のジョブが返される' do
        it 'スケジュールされたジョブが作成されない' do
          expect {
            BackgroundJob.schedule_import_searched_movies(query: query)
          }.not_to change { BackgroundJob.count }
        end

        it '実行中のジョブが返される' do
          job = BackgroundJob.schedule_import_searched_movies(query: query)
          expected_job_status = described_class.statuses.find { |_, value|
            value == already_scheduled_job_status
          }.first
          expect(job.status).to eq(expected_job_status)
        end
      end

      shared_context 'import_searched_moviesのジョブがスケジュールされない' do
        it 'スケジュールされたジョブが作成されない' do
          expect {
            BackgroundJob.schedule_import_searched_movies(query: query)
          }.not_to change { BackgroundJob.count }
        end
      end

      let(:query) { '検索クエリ' }

      context "同じジョブまたは実行中のジョブがない場合" do
        it_behaves_like 'import_searched_moviesのジョブがスケジュールされる'
      end

      context 'queryが3文字未満の場合' do
        let(:query) { '検索' }
        it_behaves_like 'import_searched_moviesのジョブがスケジュールされない'
      end

      context "同一のjob_typeが存在する場合" do
        before {
          create(:background_job,
            job_type: described_class.job_types[:import_searched_movies],
            status: already_scheduled_job_status,
            arguments: { query: already_scheduled_job_query },
            created_at: already_scheduled_job_created_at
          )
        }

        context "queryが同一の場合" do
          let(:already_scheduled_job_query) { query }
          context 'created_atが23時間前の場合' do
            let(:already_scheduled_job_created_at) { 23.hours.ago }
            context "statusがpendingの場合" do
              let(:already_scheduled_job_status) { described_class.statuses[:pending] }
              it_behaves_like 'import_searched_moviesのジョブがスケジュールされず、すでに実行中のジョブが返される'
            end
            context "statusがprocessingの場合" do
              let(:already_scheduled_job_status) { described_class.statuses[:processing] }
              it_behaves_like 'import_searched_moviesのジョブがスケジュールされず、すでに実行中のジョブが返される'
            end
            context "statusがcompleteの場合" do
              let(:already_scheduled_job_status) { described_class.statuses[:complete] }
              it_behaves_like 'import_searched_moviesのジョブがスケジュールされず、すでに実行中のジョブが返される'
            end
            context "statusがerrorの場合" do
              let(:already_scheduled_job_status) {  described_class.statuses[:error] }
              it_behaves_like 'import_searched_moviesのジョブがスケジュールされず、すでに実行中のジョブが返される'
            end
          end
          context 'created_atが25時間前の場合' do
            let(:already_scheduled_job_created_at) { 25.hours.ago }
            context "statusがpendingの場合" do
              let(:already_scheduled_job_status) { described_class.statuses[:pending] }
              it_behaves_like 'import_searched_moviesのジョブがスケジュールされず、すでに実行中のジョブが返される'
            end
            context "statusがprocessingの場合" do
              let(:already_scheduled_job_status) { described_class.statuses[:processing] }
              it_behaves_like 'import_searched_moviesのジョブがスケジュールされず、すでに実行中のジョブが返される'
            end
            context "statusがcompleteの場合" do
              let(:already_scheduled_job_status) { described_class.statuses[:complete] }
              it_behaves_like 'import_searched_moviesのジョブがスケジュールされる'
            end
            context "statusがerrorの場合" do
              let(:already_scheduled_job_status) {  described_class.statuses[:error] }
              it_behaves_like 'import_searched_moviesのジョブがスケジュールされる'
            end
          end
        end
        context "queryが異なる場合" do
          let(:already_scheduled_job_created_at) { 23.hours.ago }

          let(:already_scheduled_job_query) { 'foo' }
          context "statusがpendingの場合" do
            let(:already_scheduled_job_status) { described_class.statuses[:pending] }
            it_behaves_like 'import_searched_moviesのジョブがスケジュールされる'
          end
          context "statusがprocessingの場合" do
            let(:already_scheduled_job_status) { described_class.statuses[:processing] }
            it_behaves_like 'import_searched_moviesのジョブがスケジュールされる'
          end
          context "statusがcompleteの場合" do
            let(:already_scheduled_job_status) { described_class.statuses[:complete] }
            it_behaves_like 'import_searched_moviesのジョブがスケジュールされる'
          end
          context "statusがerrorの場合" do
            let(:already_scheduled_job_status) {  described_class.statuses[:error] }
            it_behaves_like 'import_searched_moviesのジョブがスケジュールされる'
          end
        end
      end

      context "別のjob_typeが実行中の場合" do
        # NOTE: このテストは、job_typeが異なる場合に実行中のジョブが返されることを確認するためのもの
        #       このテストが失敗する場合は、job_typeが異なる場合に実行中のジョブが返されないように修正する必要がある
      end
    end

    describe '.search' do
      let!(:job1) { create(:background_job, job_type: :import_searched_movies, status: :pending, created_at: 1.day.ago) }
      let!(:job2) { create(:background_job, job_type: :import_searched_movies, status: :processing, created_at: 2.days.ago) }
      let!(:job3) { create(:background_job, job_type: :import_searched_movies, status: :complete, created_at: 3.days.ago) }
      let!(:job4) { create(:background_job, job_type: :import_searched_movies, status: :error, created_at: 4.days.ago) }

      context 'statusとjob_typeを指定しない場合' do
        it '全てのジョブが新しい順に返されること' do
          result = described_class.search
          expect(result.map(&:id)).to eq [job1.id, job2.id, job3.id, job4.id]
        end
      end

      context 'statusを指定する場合' do
        it '指定されたstatusのジョブが新しい順に返されること' do
          result = described_class.search(status: 'pending')
          expect(result.map(&:id)).to eq [job1.id]
        end
      end

      context 'job_typeを指定する場合' do
        it '指定されたjob_typeのジョブが新しい順に返されること' do
          result = described_class.search(job_type: 'import_searched_movies')
          expect(result.map(&:id)).to eq [job1.id, job2.id, job3.id, job4.id]
        end
      end

      context 'statusとjob_typeを指定する場合' do
        it '指定されたstatusとjob_typeのジョブが新しい順に返されること' do
          result = described_class.search(status: 'processing', job_type: 'import_searched_movies')
          expect(result.map(&:id)).to eq [job2.id]
        end
      end

      context 'ページネーションが適用される場合' do
        it '指定されたページのジョブが返されること' do
          result = described_class.search(page: 2, per: 2)
          expect(result.map(&:id)).to eq [job3.id, job4.id]
        end
      end
    end

    describe '#update_progress' do
      let!(:background_job) { create(:background_job, progress: 0, total: 100) }

      context "new_totalが指定されている場合" do
        it '正しくprogressとtotalが更新される' do
          background_job.update_progress(50, new_total: 200)
          expect(background_job.progress).to eq(50)
          expect(background_job.total).to eq(200)
        end
      end

      context "new_totalが指定されていない場合" do
        before {
          background_job.update_progress(50, new_total: 100)
        }
        it '正しくprogressが更新される' do
          background_job.update_progress(55)
          expect(background_job.progress).to eq(55)
          expect(background_job.total).to eq(100)
        end
      end
    end

    describe 'after_update callback' do
      let(:background_job) { create(:background_job, status: :pending, finished_at: nil) }

      context 'statusがcompleteに更新された場合' do
        it 'finished_atが設定されること' do
          background_job.update!(status: :complete)
          expect(background_job.finished_at).not_to be_nil
        end
      end

      context 'statusがerrorに更新された場合' do
        it 'finished_atが設定されること' do
          background_job.update!(status: :error)
          expect(background_job.finished_at).not_to be_nil
        end
      end

      context 'statusがpendingに更新された場合' do
        it 'finished_atは変更されないこと' do
          expect { background_job.update!(status: :pending) }.not_to change { background_job.finished_at }
        end
      end

      context 'statusがprocessingに更新された場合' do
        it 'finished_atは変更されないこと' do
          expect { background_job.update!(status: :processing) }.not_to change { background_job.finished_at }
        end
      end
    end
  end
end
