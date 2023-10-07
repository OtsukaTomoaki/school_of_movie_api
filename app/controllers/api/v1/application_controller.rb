class Api::V1::ApplicationController < ActionController::API
  include SessionsHelper
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  skip_forgery_protection
  before_action :current_user

  def current_user
    begin
      @current_user ||= TokenService.authorization(authorization_token)
    rescue => e
      p request.headers, e
      return response_unauthorized
    end
  end

  # 200 Success
  def response_success(class_name, action_name)
    render status: 200, json: { status: 200, message: "Success #{class_name.capitalize} #{action_name.capitalize}" }
  end

  # 400 Bad Request
  def response_bad_request(errors: [])
    render status: 400, json: { status: 400, errors: errors }
  end

  # 401 Unauthorized
  def response_unauthorized(message: 'Bad Request')
    render status: 401, json: { status: 401, message: message }
  end

  # 404 Not Found
  def response_not_found(class_name = 'page')
    render status: 404, json: { status: 404, message: "#{class_name.capitalize} Not Found" }
  end

  # 409 Conflict
  def response_conflict(message: 'conflict')
    render status: 409, json: { status: 409, message: message }
  end

  # 500 Internal Server Error
  def response_internal_server_error
    render status: 500, json: { status: 500, message: 'Internal Server Error' }
  end

  def authorization_token
    return @authorization_token if @authorization_token.present?
    auth_header = request.headers['Authorization'].present? ? request.headers['Authorization'] : request.cookies["authorization"]
    @authorization_token = auth_header.split(' ').last if auth_header
    @authorization_token
  end
end
