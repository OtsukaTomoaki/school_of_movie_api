require 'rails_helper'

RSpec.describe Api::V1::MoviesController, type: :request, authentication: :skip do
  describe 'GET #index' do
    # tmdbから映画情報を取得する処理のモック
    let(:client) { instance_double("Api::TheMovieDatabase::Client") }
    let(:importer) { instance_double("Api::TheMovieDatabase::Importer") }

    before {
      allow(Api::TheMovieDatabase::Client).to receive(:new).and_return(client)
      allow(Api::TheMovieDatabase::Importer).to receive(:new).and_return(importer)

      allow(importer).to receive(:execute!)
      allow(client).to receive(:fetch_searched_list).and_return(response)
    }

    # 諸々の映画情報とジャンルのリレーションんを作成
    let!(:movie1) { FactoryBot.create(:movie, title: 'Test Movie 1', vote_count: 10, vote_average: 5.0) }
    let!(:movie2) { FactoryBot.create(:movie, title: 'Test Movie 2', vote_count: 5, vote_average: 4.0) }
    let!(:genre1) { FactoryBot.create(:movie_genre, name: 'Action', the_movie_database_id: 1) }
    let!(:genre2) { FactoryBot.create(:movie_genre, name: 'Comedy', the_movie_database_id: 2) }
    let!(:relation1) { FactoryBot.create(:movie_genre_relation, movie: movie1, movie_genre: genre1) }
    let!(:relation2) { FactoryBot.create(:movie_genre_relation, movie: movie1, movie_genre: genre2) }
    let!(:relation3) { FactoryBot.create(:movie_genre_relation, movie: movie2, movie_genre: genre2) }

    shared_context 'fetch_from_the_movie_databaseが呼ばれないこと' do
      before {
        allow(Movie).to receive(:fetch_from_the_movie_database)
      }
      it do
        subject
        expect(Movie).not_to have_received(:fetch_from_the_movie_database)
      end
    end

    shared_context 'fetch_from_the_movie_databaseが1度だけ呼び出されること' do
      before {
        allow(Movie).to receive(:fetch_from_the_movie_database)
      }
      it do
        subject
        expect(Movie).to have_received(:fetch_from_the_movie_database).once
      end
    end

    subject {
      get api_v1_movies_path, params: params
    }
    let(:params) { {} }

    context '検索クエリとジャンルIDが指定されていない場合' do
      it '全ての映画情報を取得すること' do
        subject
        expect(response).to have_http_status(:ok)
        expect(assigns(:movies)).to match_array([movie1, movie2])
      end
      it_behaves_like 'fetch_from_the_movie_databaseが呼ばれないこと'
    end

    context '検索クエリのみが指定された場合' do
      let(:params) { { q: 'Test' } }
      it '検索クエリに一致する映画情報を取得すること' do
        subject
        expect(response).to have_http_status(:ok)
        expect(assigns(:movies)).to match_array([movie1, movie2])
      end
      it_behaves_like 'fetch_from_the_movie_databaseが1度だけ呼び出されること'
    end

    context 'ジャンルIDのみが指定された場合' do
      let(:params) { { genre_id: genre1.id } }
      it '指定したジャンルに一致する映画情報を取得すること' do
        subject
        expect(response).to have_http_status(:ok)
        expect(assigns(:movies)).to match_array([movie1])
      end
      it_behaves_like 'fetch_from_the_movie_databaseが呼ばれないこと'
    end

    context '検索クエリとジャンルIDが指定された場合' do
      let(:params) { { q: 'Test', genre_id: genre2.id } }
      it '検索クエリと指定したジャンルに一致する映画情報を取得すること' do
        subject
        expect(response).to have_http_status(:ok)
        expect(assigns(:movies)).to match_array([movie1, movie2])
      end
      it_behaves_like 'fetch_from_the_movie_databaseが1度だけ呼び出されること'
    end

    context 'ページ数が指定された場合' do
      before { stub_const("Movie::PER_PAGE", 1) }
      let(:params) { { page: 2 } }
      it '指定したページの映画情報を取得すること' do
        subject
        expect(response).to have_http_status(:ok)
        expect(assigns(:movies)).to match_array([movie2])
      end
    end

    context '検索結果が11件以上の場合' do
      before { 10.times { FactoryBot.create(:movie) } }

      it '10件の映画情報を取得すること' do
        subject
        expect(response).to have_http_status(:ok)
        expect(assigns(:movies).count).to eq 10
      end
    end

    describe 'レスポンスの検証' do
      let!(:expected_response) {
        {
          movies: [
            {
              id: movie1.id,
              title: movie1.title,
              overview: movie1.overview,
              vote_count: movie1.vote_count,
              vote_average: movie1.vote_average,
              poster_path: movie1.poster_path,
              backdrop_path: movie1.backdrop_path,
              original_language: movie1.original_language,
              release_date: movie1.release_date,
              movie_genres: [
                {
                  id: genre1.id,
                  name: genre1.name
                },
                {
                  id: genre2.id,
                  name: genre2.name
                }
              ]
            },
            {
              id: movie2.id,
              title: movie2.title,
              overview: movie2.overview,
              vote_count: movie2.vote_count,
              vote_average: movie2.vote_average,
              poster_path: movie2.poster_path,
              backdrop_path: movie2.backdrop_path,
              original_language: movie2.original_language,
              release_date: movie2.release_date,
              movie_genres: [
                {
                  id: genre2.id,
                  name: genre2.name
                }
              ]
            }
          ]
        }.to_json
      }

      it '正しいJSONを返すこと' do
        subject
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(expected_response)
      end
    end
  end
end
