module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = TokenService.authorization(authorization_token)
    end

    def authorization_token
      return @authorization_token if @authorization_token.present?
      auth_header = request.headers['Authorization'].present? ? request.headers['Authorization'] : request.cookies["authorization"]
      @authorization_token = auth_header.split(' ').last if auth_header
      @authorization_token
    end
  end
end
