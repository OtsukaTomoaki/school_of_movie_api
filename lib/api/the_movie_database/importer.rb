module Api
  module TheMovieDatabase
    class Importer
      require_relative "#{Rails.root}/lib/api/the_movie_database/movie_importer"
      require_relative "#{Rails.root}/lib/api/the_movie_database/movie_genre_relation_importer"

      include ActiveModel::Model

      def initialize(params:)
        @movie_json_array = params['results']
        @movie_genre_relation_json_array = Importer.convert_movie_genre_relation_hash_array_from_json(params['results'])
      end

      def execute!
        movie_importer = Api::TheMovieDatabase::MovieImporter.new(params: @movie_json_array)
        ActiveRecord::Base.transaction do
          movie_import_result = movie_importer.execute!
          Api::TheMovieDatabase::MovieGenreRelationImporter.new(
            params: generate_movie_genre_relation_hash_array(movie_hash_array: movie_import_result)
          ).execute!
        end
      end

      private

      def generate_movie_genre_relation_hash_array(movie_hash_array:)
        movie_genre_relation_hash_array = []
        movie_hash_array.each do |movie_hash|
          movie_genre_relation_hash_array.concat(get_movie_genre_relations(
            movie_id: movie_hash[:id],
            the_movie_database_id: movie_hash[:the_movie_database_id]
          ))
        end
        movie_genre_relation_hash_array
      end

      def get_movie_genre_relations(movie_id:, the_movie_database_id:)
        movie_genres = MovieGenre.all.to_a
        @movie_genre_relation_json_array[the_movie_database_id.to_s]&.map do |genre_id|
          movie_genre = movie_genres.find { |movie_genre|
            movie_genre.the_movie_database_id == genre_id.to_s
          }
          # ジャンルのない映画は無視する
          next if movie_genre.nil?

          {
            movie_id: movie_id.to_s,
            movie_genre_id: movie_genre.id
          }
        end
      end

      def self.convert_movie_genre_relation_hash_array_from_json(movie_json_array)
        movie_json_array.map do |movie_json|
          [movie_json['id'].to_s, movie_json['genre_ids']]
        end.to_h
      end
    end
  end
end