require 'rails_helper'

RSpec.describe Api::V1::MoviesController, type: :request, authentication: :skip do
  describe 'GET #show' do
    let(:movie) { FactoryBot.create(:movie) }

    subject {
      get api_v1_movie_path(movie.id)
    }

    shared_context 'レスポンスボディの検証' do
      it do
        subject
        body = JSON.parse(response.body)
        expect(body['id']).to eq(movie.id)
        expect(body['title']).to eq(movie.title)
        expect(body['original_language']).to eq(movie.original_language)

        expect(body['overview']).to eq(movie.overview)
        expect(body['poster_path']).to eq(movie.poster_path)
        expect(body['release_date']).to eq(movie.release_date.strftime('%Y-%m-%dT%H:%M:%S.%LZ'))
        expect(body['vote_average']).to eq(movie.vote_average.to_s)
        expect(body['vote_count']).to eq(movie.vote_count)
        expect(body['movie_genres']).to match_array(
          movie.movie_genre_relations.map { |relations| relation.movie_genre }.map { |genre|
            { 'id' => genre.id, 'name' => genre.name }
          })
      end
    end

    it '指定したIDの映画情報を取得すること' do
      subject
      expect(response).to have_http_status(:ok)
      expect(assigns(:movie)).to eq(movie)
    end
    it_behaves_like 'レスポンスボディの検証'
  end
end
