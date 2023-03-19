module Api
  module TheMovieDatabase
    # require_relative "#{Rails.root}/app/models/movie"
    class MovieImporter
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :movies

      ON_DUPLICATE_UPDATE = [
        :the_movie_database_id,
        :title,
        :overview,
        :original_title,
        :adult,
        :release_date,
        :poster_path,
        :backdrop_path,
        :original_language,
        :vote_average,
        :vote_count
      ].freeze

      def initialize(params:)
        movie_json_array = params['results']
        super(
          {
            movies:
              movie_json_array.map do |movie_hash|
                Movie.new(
                  id: SecureRandom.uuid,
                  the_movie_database_id: movie_hash['id'],
                  title: movie_hash['title'],
                  overview: movie_hash['overview'],
                  original_title: movie_hash['original_title'],
                  adult: movie_hash['adult'],
                  release_date: movie_hash['release_date'].present? ? Date.strptime(movie_hash['release_date'], '%Y-%m-%d') : nil,
                  poster_path: movie_hash['poster_path'],
                  backdrop_path: movie_hash['backdrop_path'],
                  original_language: movie_hash['original_language'],
                  vote_average: movie_hash['vote_average'],
                  vote_count: movie_hash['vote_count']
                )
              end
          }
        )
      end

      def execute!
        ActiveRecord::Base.transaction do
          Movie.import self.movies, on_duplicate_key_update: ON_DUPLICATE_UPDATE
        end
      end
    end
  end
end