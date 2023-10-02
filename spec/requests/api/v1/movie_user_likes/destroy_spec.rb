require 'rails_helper'

RSpec.describe "Api::V1::MovieUserLikes", type: :request, authentication: :skip do
  describe 'DELETE #destroy' do
    let!(:user) { authenticated_user }
    let!(:movie) { FactoryBot.create(:movie) }

    subject { delete api_v1_movie_user_likes_path + "?movie_id=#{movie.id}" }
    context '正常系' do
      before do
        FactoryBot.create(:movie_user_like,
                          user_id: user.id,
                          movie_id: movie.id)
      end
      it 'レスポンスが200になり、MovieUserLikeが削除されること' do
        expect { subject }.to change(MovieUserLike, :count).by(-1)
        expect(response).to have_http_status 200
      end
    end

    context '異常系' do
      context 'movie_user_like_idがない場合' do
        it 'ActiveRecord::RecordNotFoundが発生すること' do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
