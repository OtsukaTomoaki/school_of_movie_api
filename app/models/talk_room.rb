class TalkRoom < ApplicationRecord
  has_many :talk_room_permissions, dependent: :destroy

end