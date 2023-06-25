require_relative "#{Rails.root}/lib/api/the_movie_database/client"
require_relative "#{Rails.root}/lib/api/the_movie_database/importer"

class Movie < ApplicationRecord
  has_many :movie_genre_relations
  validates :title, presence: true

  PER_PAGE = 10

  def self.search(query:, genre_ids: nil, search_genre_and: false, page:, per_page: nil)
    # movie_genresをleft joinして、titleにqueryが含まれるレコードを取得する
    movies = includes(:movie_genre_relations)
    .includes(movie_genre_relations: :movie_genre)

    if query.present?
      # queryをサニタイズする
      sanitized_q = sanitize_sql_like(query)
      movies = movies.where('title LIKE ?', "%#{sanitized_q}%")
    end

    if genre_ids.present?
      if search_genre_and
        # AND検索
        movie_ids = movies.where(movie_genre_relations: { movie_genre_id: genre_ids })
          .group('movies.id')
          .having('count(movie_genre_relations.movie_genre_id) = ?', genre_ids.count)
          .pluck(:id)
        movies = movies.where(id: movie_ids)
      else
        # OR検索
        movies = movies.where(movie_genre_relations: { movie_genre_id: genre_ids })
      end
    end

    movies.order(vote_count: :desc, vote_average: :desc)
      .page(page)
      .per(per_page ? per_page : PER_PAGE)
  end

  def self.fetch_from_the_movie_database(query:)
    # TheMovieDatabase::Clientクラスを使って、APIからデータを取得する
    client = Api::TheMovieDatabase::Client.new
    response = client.fetch_searched_list(page: 1, query: query)

    # TheMovieDatabase::Importerクラスを使って、データをDBに保存する
    importer = Api::TheMovieDatabase::Importer.new(params: response)
    importer.execute!
  end
end
