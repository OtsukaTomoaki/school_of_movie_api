require 'rails_helper'

RSpec.describe MovieSearchWord, type: :model do
  describe '.add_word' do
    before {
      allow(Rails.logger).to receive(:error)
    }
    context 'wordが空の場合' do
      it '例外が発生し、エラーログが出力されること' do
        MovieSearchWord.add_word('')
        expect(Rails.logger).to have_received(:error).once.with(ActiveRecord::RecordInvalid)
      end
    end

    context 'wordが空白の場合' do
      it '例外が発生すること' do
        MovieSearchWord.add_word(' ')
        expect(Rails.logger).to have_received(:error).once.with(ActiveRecord::RecordInvalid)
      end
    end

    context 'wordがnilの場合' do
      it '例外が発生すること' do
        MovieSearchWord.add_word(nil)
        expect(Rails.logger).to have_received(:error).once.with(ActiveRecord::RecordInvalid)
      end
    end

    context 'wordがすでにDBにある場合' do
      let!(:movie_search_word) { FactoryBot.create(:movie_search_word, word: 'test') }
      it 'countが1増えること' do
        expect { MovieSearchWord.add_word('test') }.to change { movie_search_word.reload.count }.by(1)
      end
      it 'MovieSearchWordのレコード数が変わらないこと' do
        expect { MovieSearchWord.add_word('test') }.to change { MovieSearchWord.count }.by(0)
      end
      it 'エラーログが出力されないこと' do
        MovieSearchWord.add_word('test')
        expect(Rails.logger).not_to have_received(:error)
      end
    end
    context 'wordがDBにない場合' do
      it 'MovieSearchWordのレコード数が1増えること' do
        expect { MovieSearchWord.add_word('test') }.to change { MovieSearchWord.count }.by(1)
      end
      it 'MovieSearchWordのレコードが作成されること' do
        expect { MovieSearchWord.add_word('test') }.to change { MovieSearchWord.where(word: 'test').count }.by(1)
      end
      it 'エラーログが出力されないこと' do
        MovieSearchWord.add_word('test')
        expect(Rails.logger).not_to have_received(:error)
      end
    end
  end

end