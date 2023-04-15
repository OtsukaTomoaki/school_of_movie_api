class Movie < ApplicationRecord
  has_many :movie_genre_relations
  validates :title, presence: true

  PER_PAGE = 10

  def self.search(query:, genre_id: nil, page:)
    # movie_genresをleft joinして、titleにqueryが含まれるレコードを取得する
    movies = includes(:movie_genre_relations)
    .includes(movie_genre_relations: :movie_genre)

    if query.present?
      # queryをサニタイズする
      sanitized_q = sanitize_sql_like(query)
      movies = movies.where('title LIKE ?', "%#{sanitized_q}%")
    end

    if genre_id.present?
      movies = movies.where(movie_genre: { id: genre_id } )
    end

    movies.order(vote_count: :desc, vote_average: :desc)
      .page(page)
      .per(PER_PAGE)
  end
end
