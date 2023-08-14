class Api::V1::MovieUserLikesController < ApplicationController
  def create
    movie_user_like = MovieUserLike.new(movie_user_like_params)
    movie_user_like.user_id = current_user.id
    if movie_user_like.save!
      @movie_user_like = movie_user_like
    else
      render status: :internal_server_error
    end
  end

  def destroy
    movie_id = params[:movie_id]
    movie_user_like = MovieUserLike.find_by!(
      movie_id: movie_id,
      user_id: current_user.id
    )

    if movie_user_like.destroy!
      @movie_user_like = movie_user_like
    end
  end

  private
    def movie_user_like_params
      params.require(:movie_user_like).permit(:movie_id)
    end
end
