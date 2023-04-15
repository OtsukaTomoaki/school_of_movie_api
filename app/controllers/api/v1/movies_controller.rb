class Api::V1::MoviesController < Api::V1::ApplicationController
  def index
    query = params[:q]
    page = params[:page].present? ? params[:page] : 1
    genre_id = params[:genre_id]
    @movies = Movie.search(query: query, genre_id: genre_id, page: page)
  end
end
