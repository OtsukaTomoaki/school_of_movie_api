class MovieService
  include CustomException
  require_relative "#{Rails.root}/lib/api/the_movie_database/client"
  require_relative "#{Rails.root}/lib/api/the_movie_database/importer"

  def self.import_searched_movies(query:)
    ENV['THE_MOVIE_DATABASE_REQUEST_MAX_TIMES'].to_i.times do |index|
      page = index + 1

      response = Api::TheMovieDatabase::Client.new.fetch_searched_list(page: page, query: query)
      importer = Api::TheMovieDatabase::Importer.new(params: response)
      importer.execute!

      break if response['total_pages'] <= page
      sleep(1)
    end
  end
end