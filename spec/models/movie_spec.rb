require 'rails_helper'

RSpec.describe Movie, type: :model do
  let(:movie_genre) { FactoryBot.create(:movie_genre) }

  describe 'associations' do
    before {
      FactoryBot.create(
        :movie_genre_relation,
        movie_id: movie.id,
        movie_genre_id: movie_genre.id
      )
    }
    let!(:movie) {
      described_class.create!(
        title: "test title",
        original_title: "test original title",
        the_movie_database_id: "1234",
        overview: "foo",
        original_language: "en",
        adult: false
      )
    }
    it "movie_genreが参照できること" do
      expect( movie.movie_genre_relations.first.movie_genre).to eq movie_genre
    end
  end

  describe "validations" do
    it "is valid with a title" do
      movie = Movie.new(title: "Test movie")
      expect(movie).to be_valid
    end

    it "is invalid without a title" do
      movie = Movie.new
      expect(movie).to_not be_valid
    end
  end
end
