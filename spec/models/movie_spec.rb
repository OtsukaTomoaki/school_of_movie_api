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
      let!(:query) { 'Test Movie 1' }
      subject { described_class.search(query: query, page: 1) }

      it '検索クエリに一致する映画を返すこと' do
        expect(subject).to match_array([movie1])
      end

      it '検索結果に映画の全てのジャンルが含まれること' do
        expect(subject.first.movie_genre_relations.map(&:movie_genre)).to match_array([genre1, genre2])
      end
    end

    context '検索クエリに一致する映画が複数存在する場合' do
      let!(:query) { 'Test' }
      subject { described_class.search(query: query, page: 1) }

      it '検索クエリに一致する映画をvote_countとvote_averageの降順に返すこと' do
        expect(subject).to match_array([movie1, movie2])
        expect(subject.first).to eq(movie1)
      end

      it '検索結果に全ての映画のジャンルが含まれること' do
        expect(subject.first.movie_genre_relations.map(&:movie_genre)).to match_array([genre1, genre2])
        expect(subject.last.movie_genre_relations.map(&:movie_genre)).to match_array([genre2])
      end
    end

    context '検索クエリに一致する映画が存在しない場合' do
      let!(:query) { 'Not Found' }
      subject { described_class.search(query: query, page: 1) }

      it '空の配列を返すこと' do
        expect(subject).to be_empty
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

    context 'queryが空文字の場合' do
      let!(:query) { '' }
      subject { described_class.search(query: query, page: 1) }
    end

    context 'queryがnilの場合' do
      let!(:query) { nil }
      subject { described_class.search(query: query, page: 1) }
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

  describe '#fetch_from_the_movie_database' do
    let(:response_body) do
      JSON.parse(
        {
          results: [
            {
              id: 1,
              title: 'The Shawshank Redemption',
              original_title: 'The Shawshank Redemption',
              overview: 'test',
              original_language: 'en',
              release_date: '1994-09-23',
              adult: false,
              genre_ids: []
            },
            {
              id: 2,
              title: 'The Godfather',
              original_title: 'The Godfather',
              overview: 'test',
              original_language: 'en',
              release_date: '1972-03-14',
              adult: false,
              genre_ids: []
            }
          ]
        }.to_json
      )
    end

    before do
      allow_any_instance_of(Api::TheMovieDatabase::Client).to receive(:fetch_searched_list).and_return(response_body)
    end

    it 'APIからデータを取得し、DBに保存することができる' do
      expect { described_class.fetch_from_the_movie_database(query: 'test') }.to change { Movie.count }.by(2)
    end
  end
end
