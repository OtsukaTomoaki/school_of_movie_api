module Api
  module TheMovieDatabase
    class MovieGenreImporter
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :movie_genres

      ON_DUPLICATE_UPDATE = [
        :the_movie_database_id,
        :name
      ].freeze

      def initialize(params:)
        movie_genre_json_array = params['genres']
        super(
          {
            movie_genres:
            movie_genre_json_array.map do |movie_genre_hash|
                MovieGenre.new(
                  id: SecureRandom.uuid,
                  the_movie_database_id: movie_genre_hash['id'],
                  name: movie_genre_hash['name']
                )
              end
          }
        )
      end

      def execute!
        ActiveRecord::Base.transaction do
          MovieGenre.import self.movie_genres, on_duplicate_key_update: ON_DUPLICATE_UPDATE
        end
      end
    end
  end
end