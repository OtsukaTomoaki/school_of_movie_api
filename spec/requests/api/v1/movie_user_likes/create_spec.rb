require 'rails_helper'

RSpec.describe "Api::V1::MovieUserLikes", type: :request, authentication: :skip do
  describe 'POST #update' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:movie) { FactoryBot.create(:movie) }
    let!(:params) do
      {
        movie_user_like: {
          movie_id: movie.id
        }
      }
    end

    subject { post api_v1_movie_user_likes_path, params: params }

    context '正常系' do
      context "likeを追加する場合" do
        it 'レスポンスが200になり、MovieUserLikeが作成されること' do
          expect { subject }.to change(MovieUserLike, :count).by(1)
          expect(response).to have_http_status 200
        end
      end
    end

    context '異常系' do
      let!(:like) { false }

      context 'movie_idがない場合' do
        before { params[:movie_user_like][:movie_id] = nil }

        it 'レスポンスが500になること' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end