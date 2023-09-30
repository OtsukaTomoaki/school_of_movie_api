module CookiesHelper
  def add_authorization_cookie(value)
    cookies[:authorization] = {
      domain: ENV['DOMAIN'],
      value: "bearer #{value}"
    }
  end
end