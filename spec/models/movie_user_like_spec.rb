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

  describe '.search' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:movie) { FactoryBot.create(:movie) }
    let!(:movie_user_like) do
      FactoryBot.create(:movie_user_like,
                        user_id: user.id,
                        movie_id: movie.id)
    end
    context '正常系' do
      it 'user_idを指定した場合、指定したuser_idのMovieUserLikeが返ること' do
        expect(MovieUserLike.search(user_id: user.id)).to eq [movie_user_like]
      end

      it 'movie_idを指定した場合、指定したmovie_idのMovieUserLikeが返ること' do
        expect(MovieUserLike.search(movie_id: movie.id)).to eq [movie_user_like]
      end

      it 'user_idとmovie_idを指定した場合、指定したuser_idとmovie_idのMovieUserLikeが返ること' do
        expect(MovieUserLike.search(user_id: user.id, movie_id: movie.id)).to eq [movie_user_like]
      end
    end

    context '異常系' do
      it 'user_idとmovie_idを指定した場合、指定したuser_idとmovie_idのMovieUserLikeが返ること' do
        expect(MovieUserLike.search(user_id: user.id, movie_id: movie.id)).to eq [movie_user_like]
      end
    end
  end
end
