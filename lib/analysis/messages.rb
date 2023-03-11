module Analysis
  class Messages
    require 'logger'
    require 'natto'

    EXTRACT_WORD_TYPES = ['名詞', '固有名詞'].freeze
    EXTRACT_WORD_SORTS = ['一般', '組織'].freeze
    EXCLUDES_WORDS_SORTS = ['非自立', '接尾', '代名詞'].freeze

    def self.say
      logger = Logger.new(Rails.root.join('log', 'cron.log'))
      logger.info "cron job started at #{Time.now}"
    end

    def initialize
    end

    def execute
      _execute
    end

    private

    def _execute
      # p Message.count
      natto = Natto::MeCab.new
      messages = Message.all
      messages.each { |message|
        natto.parse(message.content) do |n|
          if include_word?(n)
            puts n.surface
          end
        end
      }
    end
    def include_word?(natto_text)
      natto_words = natto_text.feature.split(',')
      EXTRACT_WORD_TYPES.include?(natto_words.first) &&
      EXTRACT_WORD_SORTS.any? { |word| natto_words.include?(word) } &&
      !EXCLUDES_WORDS_SORTS.any? { |word| natto_words.include?(word) }
    end
  end
end
