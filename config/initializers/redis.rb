Redis.current = Redis.new(url: "redis://#{ENV['REDIS_URL']}")
