module Api
  module TheMovieDatabase
    # require_relative "#{Rails.root}/app/models/movie"
    class MovieImporter
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :movies
      attribute :movie_genre_relations

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

      ON_DUPLICATE_UPDATE_FOR_MOVIE_GENRE_RELATIONS = [
        :movie_id,
        :movie_genre_id
      ].freeze

      def initialize(params:)
        movie_json_array = params['results']
        movies = []
        movie_genre_relations = []
        movie_json_array.each do |movie_hash|
          movie = MovieImporter.convert_movie_record_from_json(movie_hash)
          movies << movie
          if movie_genre_relations_by_movie = MovieImporter.convert_movie_genre_relations_record_from_json(movie, movie_hash['genre_ids'])
            movie_genre_relations.concat(
              movie_genre_relations_by_movie
            )
          end
        end
        super(
          {
            movies: movies,
            movie_genre_relations: movie_genre_relations
          }
        )
      end

      def execute!
        ActiveRecord::Base.transaction do
          Movie.import self.movies, on_duplicate_key_update: ON_DUPLICATE_UPDATE_FOR_MOVIE
          MovieGenreRelation.import self.movie_genre_relations, on_duplicate_key_update: ON_DUPLICATE_UPDATE_FOR_MOVIE_GENRE_RELATIONS
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

      def self.convert_movie_genre_relations_record_from_json(movie, movie_genre_ids)
        movie_genre_ids&.map do |movie_genre_id|
          MovieGenreRelation.new(
            movie: movie,
            movie_genre_id: movie_genre_id
          )
        end
      end
    end
  end
end