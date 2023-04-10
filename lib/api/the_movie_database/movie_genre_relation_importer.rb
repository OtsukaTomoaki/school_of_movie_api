module Api
  module TheMovieDatabase
    # require_relative "#{Rails.root}/app/models/movie"
    class MovieGenreRelationImporter
      include ActiveModel::Model

      ON_DUPLICATE_UPDATE_FOR_MOVIE_GENRE_RELATIONS = [
        :movie_id,
        :movie_genre_id
      ].freeze

      def initialize(params:)
        @movie_genre_relations = self.class.convert_movie_genre_relations(params)
      end

      def execute!
        ActiveRecord::Base.transaction do
          MovieGenreRelation.import @movie_genre_relations, on_duplicate_key_update: ON_DUPLICATE_UPDATE_FOR_MOVIE_GENRE_RELATIONS
        end
      end

      private

      def self.convert_movie_genre_relations(params)
        params.map do |movie_genre_relation|
          MovieGenreRelation.new(
            movie_id: movie_genre_relation[:movie_id],
            movie_genre_id: movie_genre_relation[:movie_genre_id]
          )
        end
      end
    end
  end
end