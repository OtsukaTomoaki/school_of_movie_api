class Api::V1::UsersController < Api::V1::ApplicationController
  # include SocialClientService
  skip_before_action :current_user, only: :create

  def profile
    @user = User.search(@current_user.id)
  end

  def create
    user = User.new(user_params)
    if avatar_image = avatar_image_params
      user.avatar_image.attach(io: avatar_image, filename: "#{Time.now.to_i}_#{user.id}.jpg" , content_type: "image/jpg" )
    end

    if user.save!
      @user = user
      @avatar_image_size = avatar_image ? avatar_image.length : 0
      return
    else
      response_internal_server_error
    end
  end

  def update
    user = User.find_by_id(params[:id])
    user.update(user_update_params)
    if avatar_image = avatar_image_params
      user.avatar_image.attach(io: avatar_image, filename: "#{Time.now.to_i}_#{user.id}.jpg" , content_type: "image/jpg" )
    end
    if user.save!
      @user = user
      @avatar_image_size = avatar_image ? avatar_image.length : 0
      return
    end
  end

  def create_with_social_accounts
    onetime_token = params[:onetime_token]
    exchange_json = OneTimeToken.find_valid_token(onetime_token)

    user = SocialClientService.create_accounts_with_google_profile!(exchange_json['token'])
    @user = user
  end

  def download_avatar_image
    avatar_image = @current_user.avatar_image.download

    if avatar_image.nil?
      File.open('app/assets/images/default_avatar_image.png') do |file|
        avatar_image = file.read
      end
    end

    send_data avatar_image, type: "image/jpg", disposition: 'inline'
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def user_update_params
      params.require(:user).permit(:name)
    end

    def avatar_image_params
      avatar_image = convert_base64_to_image(params[:user][:avatar_image])
    end

    def convert_base64_to_image(base64_image)
      if base64_image.nil?
        return nil
      end
      decoded_image = Base64.decode64(base64_image)

      file = Tempfile.new
      file.binmode
      file.write(decoded_image)
      file.rewind
      file
    end
end
