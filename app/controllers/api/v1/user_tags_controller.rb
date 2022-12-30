class Api::V1::UserTagsController < Api::V1::ApplicationController
  def index
    @user_tags = UserTag.where(user_id: @current_user.id)
  end

  def create
    user_id = @current_user.id
    @user_tag = UserTag.create!(user_tag_params)
  end

  def destroy
    @user_tags = UserTag.find_by(id: params[:id], user_id: @current_user.id)
    if @user_tags
      @user_tags.destroy!
      @id = params[:id]
    end
  end

  private
    def user_tag_params
      body = params.permit(:tag)

      {
        user_id: @current_user.id,
        tag: body[:tag]
      }
    end
end
