class Api::V1::MoviesController < Api::V1::ApplicationController
  def index
    query = params[:q]
    page = params[:page].present? ? params[:page] : 1

    genre_id = params[:genre_id]
    @movies = Movie.search(query: query, genre_id: genre_id, page: page)

    if query.present?
      @background_job = BackgroundJob.schedule_import_searched_movies(query: query)
      if page == 1
        # 検索されたワードをDBに保存する
        MovieSearchWord.add_word(query)
      end
    end
  end
end
