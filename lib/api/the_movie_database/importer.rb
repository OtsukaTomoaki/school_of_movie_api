module Api
  module TheMovieDatabase
    class Importer
      include ActiveModel::Model

      def initialize(params:)
        @movie_json_array = params['results']
        @movie_genre_relation_json_array = Importer.convert_movie_genre_relation_hash_array_from_json(params['results'])
      end

      def execute!
        movie_importer = Api::TheMovieDatabase::MovieImporter.new(param_json_array: @movie_json_array)
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
        @movie_genre_relation_json_array[the_movie_database_id].map do |genre_id|
          {
            movie_id: movie_id,
            movie_genre_id: genre_id
          }
        end
      end

      def self.convert_movie_genre_relation_hash_array_from_json(movie_json_array)
        movie_json_array.map do |movie_json|
          [movie_json['id'], movie_json['genre_ids']]
        end.to_h
      end
    end
  end
end