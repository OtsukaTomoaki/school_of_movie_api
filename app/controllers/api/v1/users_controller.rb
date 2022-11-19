class Api::V1::UsersController < ApplicationController
  skip_before_action :check_logged_in, only: :create

  def index
    @users = User.all
  end

  def create
    user = User.new(user_params)
    if avator_image = avator_image_params
      user.avator_image.attach(io: avator_image, filename: "#{Time.now.to_i}_#{user.id}.jpg" , content_type: "image/jpg" )
    end

    if user.save!
      @user = user
      @avator_image_size = avator_image ? avator_image.length : 0
      return
    else
      response_internal_server_error
    end
  end

  def avator_image_download
    user = User.first
    send_data user.avator_image.download, type: "image/jpg", disposition: 'inline'
  end


  private
    def user_params
      user = params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def avator_image_params
      avator_image = convert_base64_to_image(params[:user][:avator_image])
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
