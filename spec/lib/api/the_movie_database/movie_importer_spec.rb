require 'rails_helper'
require_relative "#{Rails.root}/lib/api/the_movie_database/movie_importer"

RSpec.describe Api::TheMovieDatabase::MovieImporter do

  RSpec::Matchers.define_negated_matcher :not_change, :change

  shared_context 'Movieに格納されたデータが正しいこと' do
    it do
      subject
      expect(movies[0].the_movie_database_id).to eq responsed_movies[0][:id].to_s
      expect(movies[0].title).to eq responsed_movies[0][:title]
      expect(movies[0].overview).to eq responsed_movies[0][:overview]
      expect(movies[0].original_title).to eq responsed_movies[0][:original_title]
      expect(movies[0].adult).to eq responsed_movies[0][:adult]
      expect(movies[0].release_date).to eq responsed_movies[0][:release_date]
      expect(movies[0].poster_path).to eq responsed_movies[0][:poster_path]
      expect(movies[0].backdrop_path).to eq responsed_movies[0][:backdrop_path]
      expect(movies[0].original_language).to eq responsed_movies[0][:original_language]
      expect(movies[0].vote_average).to eq responsed_movies[0][:vote_average]
      expect(movies[0].vote_count).to eq responsed_movies[0][:vote_count]

      expect(movies[1].the_movie_database_id).to eq responsed_movies[1][:id].to_s
      expect(movies[1].title).to eq responsed_movies[1][:title]
      expect(movies[1].overview).to eq responsed_movies[1][:overview]
      expect(movies[1].original_title).to eq responsed_movies[1][:original_title]
      expect(movies[1].adult).to eq responsed_movies[1][:adult]
      expect(movies[1].release_date).to eq responsed_movies[1][:release_date]
      expect(movies[1].poster_path).to eq responsed_movies[1][:poster_path]
      expect(movies[1].backdrop_path).to eq responsed_movies[1][:backdrop_path]
      expect(movies[1].original_language).to eq responsed_movies[1][:original_language]
      expect(movies[1].vote_average).to eq responsed_movies[1][:vote_average]
      expect(movies[1].vote_count).to eq responsed_movies[1][:vote_count]
    end
  end

  let!(:responsed_movies) {
    [
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
        vote_count: 321
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
        vote_count: 1192
      }
    ]
  }

  describe '#initialize' do
    subject { described_class.new(params: params) }

    let!(:params) {
      JSON.parse(responsed_movies.to_json)
    }
    example 'Movieが追加されないこと' do
      expect { subject }.not_to change { Movie.count }
    end

    let(:movies) { subject.movies }
    it_behaves_like 'Movieに格納されたデータが正しいこと'
  end

  describe '#execute!' do
    let!(:importer) { described_class.new(params: params) }

    let!(:params) {
      JSON.parse(responsed_movies.to_json)
    }
    subject { importer.execute! }
    context 'importする映画情報が既存のテーブルに存在しない場合' do
      example 'Movieが2件追加されること' do
        expect { subject }.to change { Movie.count }.from(0).to(2)
      end

      let(:movies) {
        Movie.all.order(:the_movie_database_id)
      }
      it_behaves_like 'Movieに格納されたデータが正しいこと'
    end

    context 'importする件の映画情報のうち1件が既存のテーブルに存在する場合' do
      before {
        FactoryBot.create(:movie, the_movie_database_id: '1')
        FactoryBot.create(:movie, the_movie_database_id: '3')
      }
      example 'Movieが2件から3件になること' do
        expect { subject }.to change { Movie.count }.from(2).to(3)
      end
      let(:movies) {
        Movie.where(the_movie_database_id: ['1', '2']).order(:the_movie_database_id)
      }
      it_behaves_like 'Movieに格納されたデータが正しいこと'

      let!(:movie_id_not_to_be_updated) { '3' }
      example 'import対象外のレコードは変更されないこと' do
        expect { subject }.to not_change {
          Movie.find_by(the_movie_database_id: [movie_id_not_to_be_updated]).title
        }.and not_change {
          Movie.find_by(the_movie_database_id: [movie_id_not_to_be_updated]).overview
        }.and not_change {
          Movie.find_by(the_movie_database_id: [movie_id_not_to_be_updated]).original_title
        }.and not_change {
          Movie.find_by(the_movie_database_id: [movie_id_not_to_be_updated]).adult
        }.and not_change {
          Movie.find_by(the_movie_database_id: [movie_id_not_to_be_updated]).release_date
        }
      end
    end
  end
end
