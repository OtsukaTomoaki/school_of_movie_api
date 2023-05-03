require_relative "#{Rails.root}/lib/api/the_movie_database/client"
require_relative "#{Rails.root}/lib/api/the_movie_database/importer"

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

      # 検索されたワードをDBに保存する
      MovieSearchWord.add_word(query)
      BackgroundJob.schedule_import_searched_movies(query: query)
    end

    if genre_id.present?
      movies = movies.where(movie_genre: { id: genre_id } )
    end

    movies.order(vote_count: :desc, vote_average: :desc)
      .page(page)
      .per(PER_PAGE)
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
