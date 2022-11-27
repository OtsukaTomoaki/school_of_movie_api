class OneTimeToken < ApplicationRecord
  before_save   :set_expires_at

  def self.find_valid_token(id)
    delete_all_expire_token
    token = find_by_id(id)

    exchange_json = token.exchange_json
    token.delete
    exchange_json
  end

  private
    def set_expires_at
      self.expires_at = Time.now + 5.minutes
    end

    def self.delete_all_expire_token
      where("expires_at < ?", Time.now ).delete_all
    end
end