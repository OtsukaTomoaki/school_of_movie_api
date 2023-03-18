require 'rails_helper'

RSpec.describe MovieGenre, type: :model do

  describe 'associations' do
    let!(:movie_genre_relations) {
      (0..5).map do
        movie = FactoryBot.create(:movie)
        FactoryBot.create(
          :movie_genre_relation,
          movie_id: movie.id,
          movie_genre_id: movie_genre.id
        )
      end
      .pluck(:movie_id, :movie_genre_id)
    }
    let!(:movie_genre) {
      described_class.create!(
        the_movie_database_id: "1234",
        name: "test name"
      )
    }
    it "movie_genre_relationsが参照できること" do
      expect(movie_genre.movie_genre_relations.pluck(:movie_id, :movie_genre_id)).to match_array movie_genre_relations
    end
  end
end
