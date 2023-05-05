class Api::V1::MoviesController < Api::V1::ApplicationController
  def index
    query = params[:q]
    page = params[:page].present? ? params[:page] : 1

    if query.present? && page == 1
      # 検索されたワードをDBに保存する
      MovieSearchWord.add_word(query)
      BackgroundJob.schedule_import_searched_movies(query: query)
    end

    genre_id = params[:genre_id]
    @movies = Movie.search(query: query, genre_id: genre_id, page: page)
  end
end
