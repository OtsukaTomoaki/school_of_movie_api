class Message < ApplicationRecord
  belongs_to :talk_room
  belongs_to :user
  validates :content, presence: true
end