# frozen_string_literal: true

# The RedisCacheService class is responsible for fetching and caching data in a Redis store.
# It provides a simple interface for storing and retrieving data from Redis, with an optional
# time-to-live (TTL) for the cached data.
class RedisCacheService
  class << self
    # Fetches the data from the Redis store, or yields a block to generate the data
    # and stores the result in the Redis store.
    # @param key [String] The key to use for storing and retrieving the cached data.
    # @param ttl [Integer] The time-to-live (TTL) for the cached data in seconds. Default is 3600 (1 hour).
    # @yield [block] A block that generates the data to be cached.
    # @return [Object] The cached data, or the result of the yielded block if the data was not found in the cache.
    def fetch(key, ttl: 3600, &block)
      new(key: key, ttl: ttl).fetch(&block)
    end

    # Retrieves the Redis connection pool for the application.
    # @return [ConnectionPool] The Redis connection pool.
    def redis_pool
      Rails.application.config.redis_pool
    end

    # Calculates the age of the cached data for a given key and expiration time.
    # @param key [String] The key of the cached data.
    # @param expiration [Integer] The expiration time of the cached data in seconds.
    # @return [Integer, nil] The age of the cached data in seconds, or nil if the data is not found or has expired.
    def age(key, expiration)
      redis_pool.with do |redis|
        ttl = redis.ttl(key)
        return nil if ttl.nil? || ttl <= 0

        expiration - ttl
      end
    end
  end

  attr_reader :key, :ttl

  # Initializes a new RedisCacheService instance.
  # @param key [String] The key to use for storing and retrieving the cached data.
  # @param ttl [Integer] The time-to-live (TTL) for the cached data in seconds. Default is 300 (5 minutes).
  def initialize(key:, ttl: 300)
    @key = key
    @ttl = ttl
  end

  # Fetches the data from the Redis store, or yields a block to generate the data
  # and stores the result in the Redis store.
  # @yield [block] A block that generates the data to be cached.
  # @return [Object] The cached data, or the result of the yielded block if the data was not found in the cache.
  def fetch
    cached_value = get

    if cached_value.nil? && block_given?
      value = yield
      set(value)
      value
    else
      begin
        JSON.parse(cached_value)
      rescue StandardError
        cached_value
      end
    end
  end

  private

  # Retrieves the Redis connection pool for the application.
  # @return [ConnectionPool] The Redis connection pool.
  def redis_pool
    Rails.application.config.redis_pool
  end

  # Retrieves the cached value from Redis.
  # @return [String, nil] The cached value, or nil if the key does not exist.
  def get
    redis_pool.with do |redis|
      redis.get(key)
    end
  end

  # Stores the value in the Redis store with the specified TTL.
  # @param value [Object] The value to be cached.
  # @return [String] The status of the Redis set operation.
  def set(value)
    redis_options = { ex: @ttl }

    redis_pool.with do |redis|
      result = redis.set(key, value.to_json, **redis_options)
      result
    end
  end

  # Retrieves the time-to-live (TTL) of the cached data.
  # @return [Integer] The remaining TTL in seconds.
  def ttl
    redis_pool.with { |redis| redis.ttl(key) }
  end

  # Checks if the cached data exists in the Redis store.
  # @return [Boolean] True if the cached data exists, false otherwise.
  def key_exists?
    redis_pool.with { |redis| redis.exists?(key) }
  end
end
