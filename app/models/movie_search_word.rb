class MovieSearchWord < ApplicationRecord
  validates :word, presence: true

  def self.add_word(word)
    begin
      # wordがすでにDBにあるか確認する
      movie_search_word = find_by(word: word)
      if movie_search_word.present?
        # wordがすでにDBにある場合は、countを1増やす
        movie_search_word.count += 1
        movie_search_word.save!
      else
        # wordがDBにない場合は、新しく作成する
        create!(word: word, count: 1)
      end
    rescue => e
      # 例外が発生した場合は、エラーログを出力する
      Rails.logger.error(e)
    end
  end
end
