require 'rails_helper'
require 'rake'
Rails.application.load_tasks

require_relative "#{Rails.root}/lib/api/the_movie_database/client"
require_relative "#{Rails.root}/lib/api/the_movie_database/response_importer"

RSpec.describe 'movies:fetch_popular_movie' do
  let(:movies_client) { instance_double(Api::TheMovieDatabase::Client) }
  let(:response_importer) { instance_double(Api::TheMovieDatabase::ResponseImporter) }
  let(:request_max_times) { 5 }

  before do
    allow(Api::TheMovieDatabase::Client).to receive(:new).and_return(movies_client)
    allow(Api::TheMovieDatabase::ResponseImporter).to receive(:new).and_return(response_importer)
    allow(response_importer).to receive(:execute!)

    ENV['THE_MOVIE_DATABASE_REQUEST_MAX_TIMES'] = request_max_times.to_s
  end
  after {
    Rake::Task['movies:fetch_popular_movie'].reenable
  }
  context "ページ数が1000件で取得する最大ページ数が3までの場合" do
    it 'fetch_popular_listが3回呼び出されること' do
      allow(movies_client).to receive(:fetch_popular_list).and_return({'total_pages' => 1000})

      expect(movies_client).to receive(:fetch_popular_list).exactly(request_max_times).times
      expect_any_instance_of(Kernel).to receive(:sleep).with(5).exactly(5).times

      Rake::Task['movies:fetch_popular_movie'].invoke
    end

    it 'Api::TheMovieDatabase::ResponseImporterのインスタンスが3回生成されること' do
      allow(movies_client).to receive(:fetch_popular_list).and_return({'total_pages' => 1000})
      expect(Api::TheMovieDatabase::ResponseImporter).to receive(:new).exactly(request_max_times).times
      expect(response_importer).to receive(:execute!).exactly(request_max_times).times
      expect_any_instance_of(Kernel).to receive(:sleep).with(5).exactly(5).times

      Rake::Task['movies:fetch_popular_movie'].invoke
    end
  end

  context "ページ数が2件で取得する最大ページ数が3までの場合" do
    it 'fetch_popular_listが2回呼び出されること' do
      allow(movies_client).to receive(:fetch_popular_list).and_return({'total_pages' => 2})

      expect(movies_client).to receive(:fetch_popular_list).ordered.with(page: 1)
      expect(movies_client).to receive(:fetch_popular_list).ordered.with(page: 2)

      expect(response_importer).to receive(:execute!).twice

      expect_any_instance_of(Kernel).to receive(:sleep).with(5).once

      Rake::Task['movies:fetch_popular_movie'].invoke
    end
  end
end
