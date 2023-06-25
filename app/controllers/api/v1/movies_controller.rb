class Api::V1::MoviesController < Api::V1::ApplicationController
  def index
    query = params[:q]
    page = params[:page].present? ? params[:page] : 1

    genre_ids = params[:genre_ids].present? ? params[:genre_ids].split(',') : nil
    search_genre_and = params[:search_genre_and] == 'true'
    per_page = params[:per_page]
    @movies = Movie.search(query: query, genre_ids: genre_ids, search_genre_and: search_genre_and, page: page, per_page: per_page)

    if query.present?
      @background_job = BackgroundJob.schedule_import_searched_movies(query: query)
      if page == 1
        # 検索されたワードをDBに保存する
        MovieSearchWord.add_word(query)
      end
    end
  end

  def show
    @movie = Movie.find(params[:id])
  end
end
