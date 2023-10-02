class Api::V1::UserTagsController < Api::V1::ApplicationController
  def index
    @user_tags = UserTag.where(user_id: @current_user.id)
    if params[:q]
      @user_tags = @user_tags.where('tag LIKE ?', "%#{params[:q]}%")
    end
    @user_tags = @user_tags.order(created_at: :desc)
  end

  def create
    user_id = @current_user.id
    body = user_tag_params
    if not UserTag.exists?(user_id: user_id, tag: body[:tag])
      @user_tag = UserTag.create!(body)
    else
      response_bad_request(message: 'すでに登録されているタグです')
    end
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
