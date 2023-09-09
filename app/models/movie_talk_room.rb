class MovieTalkRoom < ApplicationRecord
  has_one :movie
  has_one :talk_room
end
