module CookiesHelper
  def add_authorization_cookie(value)
    cookies[:authorization] = {
      domain: '192.168.32.138.nip.io',
      value: "bearer #{value}"
    }
  end
end