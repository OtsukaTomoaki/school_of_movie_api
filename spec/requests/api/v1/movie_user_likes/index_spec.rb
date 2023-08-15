require 'rails_helper'

RSpec.describe "Api::V1::MovieUserLikes", type: :request, authentication: :skip do
  describe 'GET #index' do

    let!(:user_1) { FactoryBot.create(:user) }
    let!(:user_2) { FactoryBot.create(:user) }
    let!(:user_3) { FactoryBot.create(:user) }

    let!(:movie_1) { FactoryBot.create(:movie) }
    let!(:movie_2) { FactoryBot.create(:movie) }
    let!(:movie_3) { FactoryBot.create(:movie) }

    subject { get api_v1_movie_user_likes_path, params: params }

    shared_context 'レスポンスが正しいこと' do
      let!(:excepted_length) { excepted_response.length }
      let!(:excepted_first_user_id) { excepted_response.first.user_id }
      let!(:excepted_first_movie_id) { excepted_response.first.movie_id }
      let!(:excepted_first_created_at) { excepted_response.first.created_at }
      let!(:excepted_last_user_id) { excepted_response.last.user_id }
      let!(:excepted_last_movie_id) { excepted_response.last.movie_id }
      let!(:excepted_last_created_at) { excepted_response.last.created_at }

      it 'レスポンスが200になり、指定したuser_idのMovieUserLikeが返ること' do
        subject
        expect(response).to have_http_status 200

        json = JSON.parse(response.body)
        movie_user_likes_in_body = json['movie_user_likes']
        expect(movie_user_likes_in_body.length).to eq excepted_length
        expect(movie_user_likes_in_body.first['user_id']).to eq excepted_first_user_id
        expect(movie_user_likes_in_body.first['movie_id']).to eq excepted_first_movie_id
        expect(movie_user_likes_in_body.first['created_at']).to eq excepted_first_created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ')

        expect(movie_user_likes_in_body.last['user_id']).to eq excepted_last_user_id
        expect(movie_user_likes_in_body.last['movie_id']).to eq excepted_last_movie_id
        expect(movie_user_likes_in_body.last['created_at']).to eq excepted_last_created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
      end
    end

    context '正常系' do
      context "user_id, movie_idを指定した場合" do
        let!(:params) {
          {
            user_id: user_1.id,
            movie_id: movie_1.id
          }
        }
        let!(:excepted_response) do
          [
            FactoryBot.create(:movie_user_like,
                              user_id: user_1.id,
                              movie_id: movie_1.id)
            ].reverse
        end
        before {
          FactoryBot.create(:movie_user_like,
            user_id: user_1.id,
            movie_id: movie_2.id)
          FactoryBot.create(:movie_user_like,
            user_id: user_1.id,
            movie_id: movie_3.id)
          FactoryBot.create(:movie_user_like,
            user_id: user_2.id,
            movie_id: movie_1.id)
          FactoryBot.create(:movie_user_like,
            user_id: user_2.id,
            movie_id: movie_2.id)
          FactoryBot.create(:movie_user_like,
            user_id: user_2.id,
            movie_id: movie_3.id)
        }
        it_behaves_like 'レスポンスが正しいこと'
      end
      context "user_idのみを指定した場合" do
        let!(:params) {
          {
            user_id: user_1.id
          }
        }
        let!(:excepted_response) do
          [
            FactoryBot.create(:movie_user_like,
                              user_id: user_1.id,
                              movie_id: movie_1.id),
            FactoryBot.create(:movie_user_like,
                              user_id: user_1.id,
                              movie_id: movie_2.id),
            FactoryBot.create(:movie_user_like,
                              user_id: user_1.id,
                              movie_id: movie_3.id)
          ].reverse
        end
        before {
          FactoryBot.create(:movie_user_like,
            user_id: user_2.id,
            movie_id: movie_1.id)
          FactoryBot.create(:movie_user_like,
            user_id: user_2.id,
            movie_id: movie_2.id)
          FactoryBot.create(:movie_user_like,
            user_id: user_2.id,
            movie_id: movie_3.id)
        }
        it_behaves_like 'レスポンスが正しいこと'
      end
      context "movie_idのみを指定した場合" do
        let!(:params) {
          {
            movie_id: movie_1.id
          }
        }
        let!(:excepted_response) do
          [
            FactoryBot.create(:movie_user_like,
                              user_id: user_1.id,
                              movie_id: movie_1.id),
            FactoryBot.create(:movie_user_like,
                              user_id: user_2.id,
                              movie_id: movie_1.id),
            FactoryBot.create(:movie_user_like,
                              user_id: user_3.id,
                              movie_id: movie_1.id)
            ].reverse
        end
        before {
          FactoryBot.create(:movie_user_like,
            user_id: user_1.id,
            movie_id: movie_2.id)
          FactoryBot.create(:movie_user_like,
            user_id: user_1.id,
            movie_id: movie_3.id)
          FactoryBot.create(:movie_user_like,
            user_id: user_2.id,
            movie_id: movie_2.id)
          FactoryBot.create(:movie_user_like,
            user_id: user_2.id,
            movie_id: movie_3.id)
        }
        it_behaves_like 'レスポンスが正しいこと'
      end
    end
  end
end
