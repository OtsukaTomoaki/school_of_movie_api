module UuidGenerator
  extend ActiveSupport::Concern

  def self.included(klass)
    klass.before_create :fill_uuid
  end

  def fill_uuid
    return if self.class.primary_key != 'id'
    self.id = loop do
      uuid = SecureRandom.uuid
      break uuid unless self.class.exists?(id: uuid)
    end
  end
end