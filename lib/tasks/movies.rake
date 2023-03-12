namespace :movies do
  require_relative '../api/the_movie_database/client'
  require_relative '../api/the_movie_database/response_importer'

  desc 'Update movies from TMDB API'
  task fetch: :environment do
    movies = Api::TheMovieDatabase::Client.new

    500.times do |index|
      page = index + 1
      response = movies.fetch_popular_list(page: page)
      importer = Api::TheMovieDatabase::ResponseImporter.new(params: response)
      importer.execute!
      sleep(5)
    end

  end
end
