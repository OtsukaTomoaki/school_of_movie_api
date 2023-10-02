require 'rails_helper'
require_relative "#{Rails.root}/lib/api/the_movie_database/movie_genre_relation_importer"

RSpec.describe Api::TheMovieDatabase::MovieGenreRelationImporter do
  RSpec::Matchers.define_negated_matcher :not_change, :change

  RSpec::Matchers.define_negated_matcher :not_change, :change
  let!(:movie_genre_renlation_params) {
    [
      {
        movie_id: 1,
        movie_genre_id: 11
      },
      {
        movie_id: 1,
        movie_genre_id: 12
      },
      {
        movie_id: 2,
        movie_genre_id: 12
      }
    ]
  }

  describe '#initialize' do
    let(:importer) { described_class.new(params: movie_genre_renlation_params) }
    it 'movie_genre_relationsがセットされていること' do
      expect(importer.instance_variable_get(:@movie_genre_relations)).to be_instance_of(Array)
      expect(importer.instance_variable_get(:@movie_genre_relations).count).to eq 3
      expect(importer.instance_variable_get(:@movie_genre_relations).first).to be_instance_of(MovieGenreRelation)
    end
  end

  describe '#execute!' do
    before {
      # movieの追加
      FactoryBot.create(:movie).update(id: 1)
      FactoryBot.create(:movie).update(id: 2)
      FactoryBot.create(:movie).update(id: 3)
      FactoryBot.create(:movie).update(id: 100)

      # movie_genreの追加
      FactoryBot.create(:movie_genre).update(id: 11)
      FactoryBot.create(:movie_genre).update(id: 12)
      FactoryBot.create(:movie_genre).update(id: 13)
      FactoryBot.create(:movie_genre).update(id: 200)

      FactoryBot.create(
        :movie_genre_relation,
        movie_id: 100,
        movie_genre_id: 200
      )
    }
    let(:importer) { described_class.new(params: movie_genre_renlation_params) }
    subject {
      importer.execute!
    }
    context '新規にmovie_genre_relationが3件追加される場合' do
      it '3件のレコードが追加されること' do
        expect { subject }.to change {
          MovieGenreRelation.count
        }.from(1).to(4)
        .and not_change {
          Movie.count
        }
        .and not_change {
          MovieGenre.count
        }
      end

      it '更新処理後のデータは正しいこと' do
        subject
        expect(MovieGenreRelation.where(movie_id: [1, 2]).pluck(:movie_id, :movie_genre_id)).to match_array([
          ['1', '11'],
          ['1', '12'],
          ['2', '12']
        ])
      end
    end

    context '新規にmovie_genre_relationが2件追加、すでに存在するレコードが1件存在する場合' do
      before {
        FactoryBot.create(
          :movie_genre_relation,
          movie_id: 1,
          movie_genre_id: 12
        )
      }
      it '2件のレコードが追加されること' do
        expect { subject }.to change {
          MovieGenreRelation.count
        }.from(2).to(4)
        .and not_change {
          Movie.count
        }
        .and not_change {
          MovieGenre.count
        }
      end

      it '更新処理後のデータは正しいこと' do
        subject
        expect(MovieGenreRelation.where(movie_id: [1, 2]).pluck(:movie_id, :movie_genre_id)).to match_array([
          ['1', '11'],
          ['1', '12'],
          ['2', '12']
        ])
      end
    end
  end
end
