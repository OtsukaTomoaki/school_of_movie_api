require 'rails_helper'
require 'rake'
Rails.application.load_tasks

require_relative "#{Rails.root}/lib/api/the_movie_database/client"
require_relative "#{Rails.root}/lib/api/the_movie_database/importer"

RSpec.describe 'movies:fetch_popular_movie' do
  let(:movies_client) { instance_double(Api::TheMovieDatabase::Client) }
  let(:importer) { instance_double(Api::TheMovieDatabase::Importer) }
  let(:request_max_times) { 5 }
  let(:sleep_time) { 5 }
  before do
    allow(Api::TheMovieDatabase::Client).to receive(:new).and_return(movies_client)
    allow(Api::TheMovieDatabase::Importer).to receive(:new).and_return(importer)
    allow(importer).to receive(:execute!)

    ENV['THE_MOVIE_DATABASE_REQUEST_MAX_TIMES'] = request_max_times.to_s
  end
  after {
    Rake::Task['movies:fetch_popular_movie'].reenable
  }
  context "ページ数が1000件で取得する最大ページ数が3までの場合" do
    it 'fetch_popular_listが5回呼び出されること' do
      allow(movies_client).to receive(:fetch_movie_genres).and_return({'genres' => []})
      allow(movies_client).to receive(:fetch_popular_list).and_return({'total_pages' => 1000})

      expect(movies_client).to receive(:fetch_movie_genres).exactly(1).times
      expect(movies_client).to receive(:fetch_popular_list).exactly(request_max_times).times
      expect_any_instance_of(Kernel).to receive(:sleep).with(sleep_time).exactly(5).times

      Rake::Task['movies:fetch_popular_movie'].invoke
    end

    it 'Api::TheMovieDatabase::Importerのインスタンスが5回生成されること' do
      allow(movies_client).to receive(:fetch_movie_genres).and_return({'genres' => []})
      allow(movies_client).to receive(:fetch_popular_list).and_return({'total_pages' => 1000})

      expect(movies_client).to receive(:fetch_movie_genres).once
      expect(Api::TheMovieDatabase::Importer).to receive(:new).exactly(request_max_times).times
      expect(importer).to receive(:execute!).exactly(request_max_times).times
      expect_any_instance_of(Kernel).to receive(:sleep).with(sleep_time).exactly(5).times

      Rake::Task['movies:fetch_popular_movie'].invoke
    end
  end

  context "ページ数が2件で取得する最大ページ数が3までの場合" do
    it 'fetch_popular_listが2回呼び出されること' do
      allow(movies_client).to receive(:fetch_movie_genres).and_return({'genres' => []})
      allow(movies_client).to receive(:fetch_popular_list).and_return({'total_pages' => 2})

      expect(movies_client).to receive(:fetch_movie_genres).once
      expect(movies_client).to receive(:fetch_popular_list).ordered.with(page: 1)
      expect(movies_client).to receive(:fetch_popular_list).ordered.with(page: 2)

      expect(importer).to receive(:execute!).twice

      expect_any_instance_of(Kernel).to receive(:sleep).with(sleep_time).once

      Rake::Task['movies:fetch_popular_movie'].invoke
    end
  end
end
