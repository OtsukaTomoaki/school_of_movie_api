class Api::V1::MovieTalkRoomsController < ApplicationController
  def by_movie_id
    movie_id = params[:movie_id]
    @movie_talk_room = MovieTalkRoom.find_by(movie_id: movie_id)
    if @movie_talk_room.nil?
      # トークルームが存在しない場合は作成する
      movie = Movie.find(movie_id)
      talk_room = TalkRoomService.new.create!(
          form: TalkRooms::Form.new(name: movie.title, describe: movie.overview, status: TalkRoom.statuses['release']),
          owner_user: current_user)
      @movie_talk_room = MovieTalkRoom.create!(movie_id: movie_id, talk_room_id: talk_room.id)
    end
  end
end
