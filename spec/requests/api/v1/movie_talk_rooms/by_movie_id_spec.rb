require 'rails_helper'

RSpec.describe "Api::V1::MovieTalkRooms", type: :request do
  describe "GET /movie_talk_rooms" do
    let!(:movie) { FactoryBot.create(:movie) }
    let!(:movie_id) { movie.id }

    subject {
      get "/api/v1/movie_talk_rooms/#{movie_id}"
    }

    context "正常系" do
      shared_context "200が返ること" do
        it "レスポンスが200が返ること" do
          subject
          expect(response).to have_http_status 200
        end

        it "Bodyが正しいこと" do
          subject
          expected_movie_talk_room = MovieTalkRoom.find_by(movie_id: movie_id)

          json = JSON.parse(response.body)
          expect(json['id']).to eq expected_movie_talk_room.id
          expect(json['movie_id']).to eq expected_movie_talk_room.movie_id
          expect(json['talk_room_id']).to eq expected_movie_talk_room.talk_room_id
        end
      end

      context "すでにtalk_roomが作成されている場合" do
        let!(:talk_room) {
          FactoryBot.create(:talk_room,
            name: movie.title,
            describe: movie.overview,
            status: TalkRoom.statuses['release']
          )
        }
        let!(:movie_talk_room) { FactoryBot.create(:movie_talk_room, movie_id: movie_id, talk_room_id: talk_room.id) }
        it_behaves_like "200が返ること"
      end
      context "talk_roomが作成されていない場合" do
        it_behaves_like "200が返ること"
      end
    end
  end
end
