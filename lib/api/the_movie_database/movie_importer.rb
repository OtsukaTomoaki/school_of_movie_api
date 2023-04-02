module Api
  module TheMovieDatabase
    # require_relative "#{Rails.root}/app/models/movie"
    class MovieImporter
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :movies

      ON_DUPLICATE_UPDATE_FOR_MOVIE = [
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
        tmp_movies = params.map do |movie_hash|
          MovieImporter.convert_movie_record_from_json(movie_hash)
        end
        super(
          {
            movies: tmp_movies,
          }
        )
      end

      def execute!
        ActiveRecord::Base.transaction do
          Movie.import(
            self.movies,
            on_duplicate_key_update: ON_DUPLICATE_UPDATE_FOR_MOVIE,
            returning: [:id, :the_movie_database_id]
          )
        end
      end

      private

      def self.convert_movie_record_from_json(movie_in_json)
        Movie.new(
          id: SecureRandom.uuid,
          the_movie_database_id: movie_in_json['id'],
          title: movie_in_json['title'],
          overview: movie_in_json['overview'],
          original_title: movie_in_json['original_title'],
          adult: movie_in_json['adult'],
          release_date: movie_in_json['release_date'].present? ? Date.strptime(movie_in_json['release_date'], '%Y-%m-%d') : nil,
          poster_path: movie_in_json['poster_path'],
          backdrop_path: movie_in_json['backdrop_path'],
          original_language: movie_in_json['original_language'],
          vote_average: movie_in_json['vote_average'],
          vote_count: movie_in_json['vote_count']
        )
      end
    end
  end
end