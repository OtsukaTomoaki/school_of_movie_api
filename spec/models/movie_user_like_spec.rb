require 'rails_helper'

RSpec.describe MovieUserLike, type: :model do
  describe 'バリデーション' do
    let!(:movie_id) { FactoryBot.create(:movie).id }
    let!(:user_id) { FactoryBot.create(:user).id }

    context '正常系' do
      let!(:movie_user_like) do
        FactoryBot.build(:movie_user_like, movie_id: movie_id, user_id: user_id)
      end
      it 'movie_idとuser_idがあれば有効' do
        expect(movie_user_like).to be_valid
      end
    end

    context '異常系' do
      let!(:movie_user_like) do
        FactoryBot.build(:movie_user_like)
      end
      it 'movie_idがなければ無効' do
        movie_user_like.movie_id = nil
        expect(movie_user_like).to be_invalid
      end

      it 'user_idがなければ無効' do
        movie_user_like.user_id = nil
        expect(movie_user_like).to be_invalid
      end

      it 'movie_idとuser_idの組み合わせが重複していたら無効' do
        FactoryBot.create(:movie_user_like,
                          movie_id: movie_id,
                          user_id: user_id)
        movie_user_like.movie_id = movie_id
        movie_user_like.user_id = user_id
        expect(movie_user_like).to be_invalid
      end
    end
  end
end
