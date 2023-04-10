class Movie < ApplicationRecord
  has_many :movie_genre_relations
  validates :title, presence: true
end
