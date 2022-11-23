class OneTimeToken < ApplicationRecord
  before_save   :set_expires_at

  def self.find_valid_token(id)
    delete_all_expire_token
    token = find_by_id(id)

    exchange_token = token.exchange_token
    token.delete
    exchange_token
  end

  private
    def set_expires_at
      self.expires_at = Time.now + 5.minutes
    end

    def self.delete_all_expire_token
      where("expires_at < ?", Time.now ).delete_all
    end
end