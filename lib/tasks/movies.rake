namespace :movies do
  require_relative '../api/the_movie_database/client'
  require_relative '../api/the_movie_database/response_importer'

  desc 'Update movies from TMDB API'
  task fetch_popular_movie: :environment do
    movies = Api::TheMovieDatabase::Client.new

    ENV['THE_MOVIE_DATABASE_REQUEST_MAX_TIMES'].to_i.times do |index|
      page = index + 1
      response = movies.fetch_popular_list(page: page)
      importer = Api::TheMovieDatabase::ResponseImporter.new(params: response)
      importer.execute!

      break if response['total_pages'] <= page

      sleep(5)
    end

  end
end
