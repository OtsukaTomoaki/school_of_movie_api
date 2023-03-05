# Redis.current = Redis.new(url: "redis://#{ENV['REDIS_URL']}")
# Redis クライアントの初期化
redis_client = Redis.new(url: "redis://#{ENV['REDIS_URL']}")

# グローバル変数に設定
Rails.application.config.redis = redis_client

# # グローバルでの使用
# Rails.application.config.redis.get("key_name")
# Rails.application.config.redis.set("key_name", "value")
