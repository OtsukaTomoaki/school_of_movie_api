class TalkRoom < ApplicationRecord
  has_many :talk_room_permissions, dependent: :destroy
  validates :name, presence: true
  enum :status, { draft: 1, unlisted: 2, release: 3 }
end