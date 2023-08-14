class MovieUserLike < ApplicationRecord
  belongs_to :movie
  belongs_to :user
  validates :movie_id, presence: true
  validates :user_id, presence: true
  validates :movie_id, uniqueness: { scope: :user_id }

  def self.search(user_id: nil, movie_id: nil)
    movie_user_likes = MovieUserLike
    if user_id.present?
      movie_user_likes = movie_user_likes.where(user_id: user_id)
    end

    if movie_id.present?
      movie_user_likes = movie_user_likes.where(movie_id: movie_id)
    end

    movie_user_likes.order(created_at: :desc)
  end
end
