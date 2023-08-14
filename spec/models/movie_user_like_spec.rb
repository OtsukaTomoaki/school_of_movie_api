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
      context 'movie_user_likeが1件のみの場合' do
        let!(:excepted_movie_user_likes) { [movie_user_like] }
        let!(:user_id) { user.id }
        let!(:movie_id) { movie.id }

        it 'user_idを指定した場合、指定したuser_idのMovieUserLikeが返ること' do
          expect(MovieUserLike.search(user_id: user_id)).to eq excepted_movie_user_likes
        end

        it 'movie_idを指定した場合、指定したmovie_idのMovieUserLikeが返ること' do
          expect(MovieUserLike.search(movie_id: movie_id)).to eq excepted_movie_user_likes
        end

        it 'user_idとmovie_idを指定した場合、指定したuser_idとmovie_idのMovieUserLikeが返ること' do
          expect(MovieUserLike.search(user_id: user_id, movie_id: movie_id)).to eq excepted_movie_user_likes
        end
      end

      context '合計のmovie_user_likeが10件以上の場合' do
        before {
          10.times do |_|
            user = FactoryBot.create(:user)
            movie = FactoryBot.create(:movie)
            FactoryBot.create(:movie_user_like,
                                user_id: user.id,
                                movie_id: movie.id)
          end
        }

        context 'user_id, movie_idがそれぞれ2件一致する場合' do
          let!(:movie_user_like_only_user_match) do
            unmatch_movie = FactoryBot.create(:movie)
            FactoryBot.create(
              :movie_user_like,
              movie_id: unmatch_movie.id,
              user_id: user.id
            )
          end
          let!(:movie_user_like_only_movie_match) do
            unmatch_user = FactoryBot.create(:user)
            FactoryBot.create(
              :movie_user_like,
              movie_id: movie.id,
              user_id: unmatch_user.id
            )
          end

          let!(:user_id) { user.id }
          let!(:movie_id) { movie.id }

          it 'user_idを指定した場合、指定したuser_idのMovieUserLikeが返ること' do
            expect(MovieUserLike.search(user_id: user_id)).to eq [movie_user_like, movie_user_like_only_user_match].reverse
          end

          it 'movie_idを指定した場合、指定したmovie_idのMovieUserLikeが返ること' do
            expect(MovieUserLike.search(movie_id: movie_id)).to eq [movie_user_like, movie_user_like_only_movie_match].reverse
          end

          it 'user_idとmovie_idを指定した場合、指定したuser_idとmovie_idのMovieUserLikeが返ること' do
            expect(MovieUserLike.search(user_id: user_id, movie_id: movie_id)).to eq [movie_user_like]
          end
        end
      end
    end

    context '異常系' do
      context 'user_idが存在しない場合' do
        it '空の配列が返ること' do
          expect(MovieUserLike.search(user_id: 'not_exist_user_id')).to eq []
        end
      end

      context 'movie_idが存在しない場合' do
        it '空の配列が返ること' do
          expect(MovieUserLike.search(movie_id: 'not_exist_movie_id')).to eq []
        end
      end

      context 'user_idとmovie_idが存在しない場合' do
        it '空の配列が返ること' do
          expect(MovieUserLike.search(user_id: 'not_exist_user_id', movie_id: 'not_exist_movie_id')).to eq []
        end
      end
    end
  end
end
