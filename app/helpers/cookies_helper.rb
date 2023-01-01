module CookiesHelper
  def add_authorization_cookie(value)
    cookies[:authorization] = {
      domain: 'localhost',
      value: "bearer #{value}"
    }
  end
end