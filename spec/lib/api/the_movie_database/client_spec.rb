require 'rails_helper'
require 'webmock/rspec'
require_relative "#{Rails.root}/lib/api/the_movie_database/client"

RSpec.describe Api::TheMovieDatabase::Client do
  before do
    Api::TheMovieDatabase::Client::BASE_URL = 'https://test.org/3'
    Api::TheMovieDatabase::Client::API_KEY = 'dummy_api_key'
  end

  after do
    Api::TheMovieDatabase::Client::BASE_URL = ENV['THE_MOVIE_DATABASE_URL']
    Api::TheMovieDatabase::Client::API_KEY = ENV['THE_MOVIE_DATABASE_API_KEY']
  end

  describe '#fetch_popular_list' do

    let!(:dummy_url) { 'https://test.org/3/movie/popular?api_key=dummy_api_key&language=ja&page=1' }
    let!(:client) { described_class.new }
    context 'ステータスコード: 200がレスポンスされる場合' do
      let(:response_body) do
        {
          results: [
            {
              id: 1,
              title: 'The Shawshank Redemption'
            },
            {
              id: 2,
              title: 'The Godfather'
            }
          ]
        }
      end

      before do
        stub_request(:get, dummy_url)
          .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      let!(:excepted_body) { JSON.parse(response_body.to_json) }

      subject { client.fetch_popular_list }
      it '人気の映画一覧が取得できる' do
        expect(subject).to eq(excepted_body)
      end
    end

    context '2回のリクエストで503, 3回目のリクエストで200がレスポンスされる場合' do
      let(:response_body) do
        {
          results: [
            {
              id: 3,
              title: 'The Dark Knight'
            }
          ]
        }
      end

      before do
        stub_request(:get, dummy_url)
          .to_return(status: 500).times(2)
          .then.to_return(status: 200, body: response_body.to_json, headers: {})
      end

      let!(:excepted_body) { JSON.parse(response_body.to_json) }

      it 'retries the request and fetches a popular movie list' do
        response = client.fetch_popular_list
        expect(response).to eq(excepted_body)
      end
    end

    context '3回のリクエストで500がレスポンスされる場合' do
      let(:response_body) do
        {
          errors: [
              "page must be less than or equal to 500"
          ],
          success: false
        }
      end

      before do
        stub_request(:get, dummy_url)
          .to_return(status: 500, body: response_body.to_json, headers: {})
          .times(3)
          .then.to_return(status: 200, body: response_body.to_json, headers: {})
      end

      it 'fails to fetch a popular movie list after retrying' do
        response = client.fetch_popular_list

        expect(response).to be_nil
      end
    end
  end
end
