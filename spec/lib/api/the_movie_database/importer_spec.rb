require 'rails_helper'
require_relative "#{Rails.root}/lib/api/the_movie_database/importer"

RSpec.describe Api::TheMovieDatabase::Importer do

  RSpec::Matchers.define_negated_matcher :not_change, :change

  shared_context '映画情報のJSON' do
    let!(:json_of_2_movie_with_3_genres) {
      JSON.parse({
        results: [
          {
            id: 1,
            title: 'foo_bar',
            overview: 'this movie is great!!' * 10,
            original_title: 'foo_bar',
            adult: false,
            release_date: '2022-01-12',
            poster_path: 'sample/poster_path/1',
            backdrop_path: 'sample/backdrop_path/1',
            original_language: 'en',
            vote_average: 3.14,
            vote_count: 321,
            genre_ids: [
              1,
              2,
              3
            ]
          },
          {
            id: 2,
            title: 'ほげ_ふが',
            overview: 'ほげ_ふが_ぴよ_' * 10,
            original_title: 'ほげ_ふが',
            adult: false,
            release_date: '1993-01-12',
            poster_path: 'sample/poster_path/2',
            backdrop_path: 'sample/backdrop_path/2',
            original_language: 'ja',
            vote_average: 8.931,
            vote_count: 1192,
            genre_ids: [
              2,
              3,
              4
            ]
          }
        ]
      }.to_json)
    }

    let(:json_of_1_movie_with_3_genres_set_and_1_movie_with_no_genre_set) {
      JSON.parse({
        results: [
          {
            id: 1,
            title: 'foo_bar',
            overview: 'this movie is great!!' * 10,
            original_title: 'foo_bar',
            adult: false,
            release_date: '2022-01-12',
            poster_path: 'sample/poster_path/1',
            backdrop_path: 'sample/backdrop_path/1',
            original_language: 'en',
            vote_average: 3.14,
            vote_count: 321,
            genre_ids: [
              1,
              2,
              3
            ]
          },
          {
            id: 2,
            title: 'ほげ_ふが',
            overview: 'ほげ_ふが_ぴよ_' * 10,
            original_title: 'ほげ_ふが',
            adult: false,
            release_date: '1993-01-12',
            poster_path: 'sample/poster_path/2',
            backdrop_path: 'sample/backdrop_path/2',
            original_language: 'ja',
            vote_average: 8.931,
            vote_count: 1192,
            genre_ids: []
          },
        ]
      }.to_json)
    }
  end
  describe '#initialize' do
    include_context '映画情報のJSON'
    let!(:importer) {
      described_class.new(params: json_of_2_movie_with_3_genres)
    }
    it 'インスタンス変数に正しく値がセットされていること' do
      expect(importer.instance_variable_get(:@movie_json_array)).to be_instance_of(Array)
      expect(importer.instance_variable_get(:@movie_genre_relation_json_array)).to be_instance_of(Hash)
    end
  end

  describe '#execute!' do
    include_context '映画情報のJSON'
    before {
      FactoryBot.create(:movie_genre, the_movie_database_id: 1).update(id: 'a')
      FactoryBot.create(:movie_genre, the_movie_database_id: 2).update(id: 'b')
      FactoryBot.create(:movie_genre, the_movie_database_id: 3).update(id: 'c')
      FactoryBot.create(:movie_genre, the_movie_database_id: 4).update(id: 'd')
    }

    subject { importer.execute! }

    context '全てのコードが新規に作成される場合' do
      let(:importer) {
        described_class.new(params: json_of_2_movie_with_3_genres)
      }
      it 'moviesが2件, movie_genre_relationsが6件追加されること' do
        expect { subject }.to change {
          Movie.count
        }.from(0).to(2)
        .and change {
          MovieGenreRelation.count
        }.from(0).to(6)
        .and not_change {
          MovieGenre.count
        }
      end
    end
    context 'movies, movie_genre_relationsそれぞれ1件のレコードが更新され、他は新規追加の場合' do
      before {
        movie_id = FactoryBot.create(
          :movie,
          the_movie_database_id: 1
        ).id
        FactoryBot.create(
          :movie_genre_relation,
          movie_id: movie_id,
          movie_genre_id: 'a'
        )
      }
      let(:importer) {
        described_class.new(params: json_of_2_movie_with_3_genres)
      }
      it 'moviesが1件, movie_genre_relationsが5件追加されること' do
        expect { subject }.to change {
          Movie.count
        }.from(1).to(2)
        .and change {
          MovieGenreRelation.count
        }.from(1).to(6)
        .and not_change {
          MovieGenre.count
        }
      end
    end
  end

  describe '#generate_movie_genre_relation_hash_array' do
    include_context '映画情報のJSON'
    before {
      FactoryBot.create(:movie_genre, the_movie_database_id: 1).update(id: 'a')
      FactoryBot.create(:movie_genre, the_movie_database_id: 2).update(id: 'b')
      FactoryBot.create(:movie_genre, the_movie_database_id: 3).update(id: 'c')
      FactoryBot.create(:movie_genre, the_movie_database_id: 4).update(id: 'd')
    }
    subject { importer.send(:generate_movie_genre_relation_hash_array, movie_hash_array: params) }
    let(:importer) { described_class.new(params: import_params) }
    context "3件のジャンル情報が設定された映画が2つある場合" do
      let(:import_params) { json_of_2_movie_with_3_genres }

      let(:params) do
        [
          {
            id: 1,
            the_movie_database_id: 1
          },
          {
            id: 2,
            the_movie_database_id: 2
          }
        ]
      end

      it "6件の映画とジャンルのリレーションが返されること" do
        expect(subject).to match_array [
          { movie_id: '1', movie_genre_id: 'a' },
          { movie_id: '1', movie_genre_id: 'b' },
          { movie_id: '1', movie_genre_id: 'c' },
          { movie_id: '2', movie_genre_id: 'b' },
          { movie_id: '2', movie_genre_id: 'c' },
          { movie_id: '2', movie_genre_id: 'd' }
        ]
      end
    end

    context "2つのジャンルが設定された映画が1つ、ジャンルの設定されていない映画が1つある場合" do
      let(:import_params) { json_of_1_movie_with_3_genres_set_and_1_movie_with_no_genre_set }

      let(:params) do
        [
          {
            id: 1,
            the_movie_database_id: 1
          },
          {
            id: 2,
            the_movie_database_id: 2
          }
        ]
      end

      it "3件の映画とジャンルのリレーションが返されること" do
        expect(subject).to match_array [
          { movie_id: '1', movie_genre_id: 'a' },
          { movie_id: '1', movie_genre_id: 'b' },
          { movie_id: '1', movie_genre_id: 'c' }
        ]
      end
    end
  end
end
