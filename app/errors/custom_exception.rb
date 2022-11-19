module CustomException
  class UnAuthorizationError < StandardError
    def initialize(message = 'アクセストークンが必要です。')
      super(message)
    end
  end

  class InvalidJwtError < StandardError
    def initialize(message = '無効なトークンです。')
      super(message)
    end
  end

  class InvalidRemenberTokenError < StandardError
    def initialize(message = 'リメンバートークンが無効です。')
      super(message)
    end
  end
end