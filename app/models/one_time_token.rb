class OneTimeToken < ApplicationRecord
  before_save   :set_expires_at
  after_find    :delete_all_expire_token

  private
    def set_expires_at
      self.expires_at = Time.now + 5.minutes
    end

    def delete_all_expire_token
      where("expires_at > ?", Time.now ).delete_all
    end
end