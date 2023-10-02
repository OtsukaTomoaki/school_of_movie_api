require 'rails_helper'
require 'webmock/rspec'
require_relative "#{Rails.root}/lib/api/the_movie_database/movie_genre_importer"

RSpec.describe Api::TheMovieDatabase::MovieGenreImporter do

  RSpec::Matchers.define_negated_matcher :not_change, :change

  shared_context 'MovieGenreに格納されたデータが正しいこと' do
    it do
      subject
      expect(movie_genres[0].the_movie_database_id).to eq responsed_movie_genres[0][:id].to_s
      expect(movie_genres[0].name).to eq responsed_movie_genres[0][:name]

      expect(movie_genres[1].the_movie_database_id).to eq responsed_movie_genres[1][:id].to_s
      expect(movie_genres[1].name).to eq responsed_movie_genres[1][:name]
    end
  end

  let!(:responsed_movie_genres) {
    [
      {
        id: 1,
        name: 'foo_bar',
      },
      {
        id: 2,
        name: 'ほげ_ふが',
      }
    ]
  }

  describe '#initialize' do
    subject { described_class.new(params: params) }

    let!(:params) {
      results = {
        genres: responsed_movie_genres
      }
      JSON.parse(results.to_json)
    }
    example 'Movieが追加されないこと' do
      expect { subject }.not_to change { MovieGenre.count }
    end
    let!(:movie_genres) {
      subject.movie_genres
    }
    it_behaves_like 'MovieGenreに格納されたデータが正しいこと'
  end

  describe '#execute!' do
    let!(:importer) { described_class.new(params: params) }

    let!(:params) {
      results = {
        genres: responsed_movie_genres
      }
      JSON.parse(results.to_json)
    }
    subject { importer.execute! }
    context 'importする映画ジャンルが既存のテーブルに存在しない場合' do
      example 'MovieGenreが2件追加されること' do
        expect { subject }.to change { MovieGenre.count }.from(0).to(2)
      end

      let(:movie_genres) {
        MovieGenre.all.order(:the_movie_database_id)
      }
      it_behaves_like 'MovieGenreに格納されたデータが正しいこと'
    end

    context 'importする件の映画ジャンルのうち1件が既存のテーブルに存在する場合' do
      before {
        FactoryBot.create(:movie_genre, the_movie_database_id: '1')
        FactoryBot.create(:movie_genre, the_movie_database_id: '3')
      }
      example 'MovieGenreが2件から3件になること' do
        expect { subject }.to change { MovieGenre.count }.from(2).to(3)
      end
      let(:movie_genres) {
        MovieGenre.where(the_movie_database_id: ['1', '2']).order(:the_movie_database_id)
      }
      it_behaves_like 'MovieGenreに格納されたデータが正しいこと'

      let!(:movie_genre_id_not_to_be_updated) { '3' }
      example 'import対象外のレコードは変更されないこと' do
        expect { subject }.to not_change {
          MovieGenre.find_by(the_movie_database_id: [movie_genre_id_not_to_be_updated]).name
        }
      end
    end
  end
end
