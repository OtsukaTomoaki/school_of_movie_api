require 'rails_helper'

RSpec.describe "Api::V1::MovieTalkRooms", type: :request do
  describe "GET /movie_talk_rooms" do
    let!(:movie_id) { FactoryBot.create(:movie).id }

    subject {
      get "/api/v1/movie_talk_rooms/#{movie_id}"
    }

    context "正常系" do
      shared_context "200が返ること" do
        it "レスポンスが200になり、movie_talk_roomが返ること" do
          subject
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)
          expect(json['id']).to eq movie_talk_room.id
        end
      end

      context "すでにtalk_roomが作成されている場合" do
        let!(:movie) { FactoryBot.create(:movie) }
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
        
      end
    end
  end
end
