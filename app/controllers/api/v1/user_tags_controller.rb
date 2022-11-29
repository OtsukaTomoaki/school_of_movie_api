class Api::V1::UserTagsController < ApplicationController
  def create
    user_id = @current_user.id
    @user_tag = UserTag.create!(user_tag_params)
  end

  private
    def user_tag_params
      body = params.require(:user_tag).permit(:tag)

      {
        user_id: @current_user.id,
        tag: body[:tag]
      }
    end
end
