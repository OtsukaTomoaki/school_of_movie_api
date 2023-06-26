require 'rails_helper'

RSpec.describe 'Api::V1::MovieGenres', type: :request do
  describe 'GET /index' do
    let!(:movie_genre1) { create(:movie_genre, name: 'genre1', the_movie_database_id: 3) }
    let!(:movie_genre2) { create(:movie_genre, name: 'genre2', the_movie_database_id: 2) }
    let!(:movie_genre3) { create(:movie_genre, name: 'genre3', the_movie_database_id: 1) }

    before do
      get api_v1_movie_genres_path, params: params
    end

    let(:params) { {} }

    let(:excepted_response) {
      [movie_genre3, movie_genre2, movie_genre1].map { |m|
        {
          'id' => m.id,
          'name' => m.name,
          'the_movie_database_id' => m.the_movie_database_id,
          'created_at' => m.created_at.as_json,
          'updated_at' => m.updated_at.as_json
        }
      }
    }
    it '全てのジャンルがthe_movie_database_idの昇順に返されること' do
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['movie_genres']).to eq excepted_response
    end

  end
end