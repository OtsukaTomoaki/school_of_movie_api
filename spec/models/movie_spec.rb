require 'rails_helper'

RSpec.describe Movie, type: :model do
  let(:movie_genre) { FactoryBot.create(:movie_genre) }

  describe '#associations' do
    before {
      FactoryBot.create(
        :movie_genre_relation,
        movie_id: movie.id,
        movie_genre_id: movie_genre.id
      )
    }
    let!(:movie) {
      described_class.create!(
        title: 'test title',
        original_title: 'test original title',
        the_movie_database_id: '1234',
        overview: 'foo',
        original_language: 'en',
        adult: false
      )
    }
    it 'movie_genreが参照できること' do
      expect( movie.movie_genre_relations.first.movie_genre).to eq movie_genre
    end
  end

  describe '#validations' do
    it 'is valid with a title' do
      movie = Movie.new(title: 'Test movie')
      expect(movie).to be_valid
    end

    it 'is invalid without a title' do
      movie = Movie.new
      expect(movie).to_not be_valid
    end
  end

  describe '#search' do
    let!(:movie1) { FactoryBot.create(:movie, title: 'Test Movie 1', vote_count: 10, vote_average: 5.0) }
    let!(:movie2) { FactoryBot.create(:movie, title: 'Test Movie 2', vote_count: 5, vote_average: 4.0) }
    let!(:movie3) { FactoryBot.create(:movie, title: 'Another Movie', vote_count: 2, vote_average: 3.0) }
    let!(:genre1) { FactoryBot.create(:movie_genre, name: 'Action') }
    let!(:genre2) { FactoryBot.create(:movie_genre, name: 'Comedy') }
    let!(:genre3) { FactoryBot.create(:movie_genre, name: 'Drama') }
    let!(:relation1) { FactoryBot.create(:movie_genre_relation, movie: movie1, movie_genre: genre1) }
    let!(:relation2) { FactoryBot.create(:movie_genre_relation, movie: movie1, movie_genre: genre2) }
    let!(:relation3) { FactoryBot.create(:movie_genre_relation, movie: movie2, movie_genre: genre2) }

    context '検索クエリに一致する映画が1件だけ存在する場合' do
      it '検索クエリに一致する映画を返すこと' do
        result = described_class.search(query: 'Test Movie 1', page: 1)
        expect(result).to match_array([movie1])
      end

      it '検索結果に映画の全てのジャンルが含まれること' do
        result = described_class.search(query: 'Test Movie 1', page: 1)
        expect(result.first.movie_genre_relations.map(&:movie_genre)).to match_array([genre1, genre2])
      end
    end

    context '検索クエリに一致する映画が複数存在する場合' do
      it '検索クエリに一致する映画をvote_countとvote_averageの降順に返すこと' do
        result = described_class.search(query: 'Test', page: 1)
        expect(result).to match_array([movie1, movie2])
        expect(result.first).to eq(movie1)
      end

      it '検索結果に全ての映画のジャンルが含まれること' do
        result = described_class.search(query: 'Test', page: 1)
        expect(result.first.movie_genre_relations.map(&:movie_genre)).to match_array([genre1, genre2])
        expect(result.last.movie_genre_relations.map(&:movie_genre)).to match_array([genre2])
      end
    end

    context '検索クエリに一致する映画が存在しない場合' do
      it '空の配列を返すこと' do
        result = described_class.search(query: 'Not Found', page: 1)
        expect(result).to be_empty
      end
    end

    context 'ページ数が1の場合' do
      before do
        stub_const("#{described_class}::PER_PAGE", 1)
      end
      it '1ページ目の結果を、ページング後の映画数がPER_PAGE以下になるように返すこと' do
        result = described_class.search(query: 'Test', page: 1)
        expect(result.count).to be <= described_class::PER_PAGE
      end

      it '1ページ目の結果をvote_countとvote_averageの降順に返すこと' do
        result = described_class.search(query: 'Test', page: 1)
        expect(result.first).to eq(movie1)
      end
    end

    context 'ページ数が2以上の場合' do
      before do
        stub_const("#{described_class}::PER_PAGE", 1)
      end
      it '指定したページの結果を、ページング後の映画数がPER_PAGE以下になるように返すこと' do
        result = described_class.search(query: 'Test', page: 2)
        expect(result.count).to be <= described_class::PER_PAGE
      end

      it '指定したページの結果をvote_countとvote_averageの降順に返すこと' do
        result = described_class.search(query: 'Test', page: 2)
        expect(result.first).to eq(movie2)
      end
    end

    context 'ジャンルを指定した場合' do
      it '指定したジャンルに一致する映画を返すこと' do
        result = described_class.search(query: '', page: 1, genre_id: genre1.id)
        expect(result).to match_array([movie1])
      end

      it 'ジャンルに一致する映画をvote_countとvote_averageの降順に返すこと' do
        result = described_class.search(query: '', page: 1, genre_id: genre2.id)
        expect(result).to match_array([movie1, movie2])
        expect(result.first).to eq(movie1)
      end

      it '存在しないジャンルが指定された場合、空の配列を返すこと' do
        result = described_class.search(query: '', page: 1, genre_id: -1)
        expect(result).to be_empty
      end
    end
  end
end