require 'rails_helper'

RSpec.describe MovieGenreRelation, type: :model do
  let(:movie) { FactoryBot.create(:movie) }
  let(:genre) { FactoryBot.create(:movie_genre) }

  describe 'associations' do
    let!(:movie_genre_relation) {
      described_class.new(
        movie_id: movie.id,
        movie_genre_id: genre.id
      )
    }
    it "movieが参照できること" do
      expect( movie_genre_relation.movie).to eq movie
    end
    it "movie_genreが参照できること" do
      expect( movie_genre_relation.movie_genre).to eq genre
    end
  end
end
