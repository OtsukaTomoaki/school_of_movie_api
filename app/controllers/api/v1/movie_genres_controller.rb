class Api::V1::MovieGenresController < Api::V1::ApplicationController
  def index
    @movie_genres = MovieGenre.all.order(the_movie_database_id: :asc)
  end
end
