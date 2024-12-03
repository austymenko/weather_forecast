# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RedisCacheService do
  # mock redis instance with basic functionality
  let(:mock_redis) { instance_double('Redis') }

  # mock connection pool that yields our mock redis
  let(:mock_redis_pool) do
    instance_double('ConnectionPool').tap do |pool|
      allow(pool).to receive(:with).and_yield(mock_redis)
    end
  end

  # sample data for testing
  let(:test_key) { 'test_cache_key' }
  let(:test_value) { { 'name' => 'test', 'value' => 123 } }
  let(:test_ttl) { 300 }

  # json string representation of our test value
  let(:test_value_json) { test_value.to_json }

  before do
    # configure rails to use our mock redis pool
    allow(Rails.application.config).to receive(:redis_pool).and_return(mock_redis_pool)
  end

  describe '.fetch' do
    it 'creates a new instance and calls fetch on it' do
      service_instance = instance_double(described_class)
      allow(described_class).to receive(:new).with(key: test_key, ttl: test_ttl).and_return(service_instance)
      expect(service_instance).to receive(:fetch)

      described_class.fetch(test_key, ttl: test_ttl)
    end
  end

  describe '.age' do
    context 'when key exists with valid ttl' do
      it 'calculates correct age based on expiration and remaining ttl' do
        expiration = 3600
        remaining_ttl = 1800
        expected_age = expiration - remaining_ttl

        allow(mock_redis).to receive(:ttl).with(test_key).and_return(remaining_ttl)

        age = described_class.age(test_key, expiration)
        expect(age).to eq(expected_age)
      end
    end

    context 'when key does not exist or has expired' do
      it 'returns nil for negative ttl' do
        allow(mock_redis).to receive(:ttl).with(test_key).and_return(-1)
        expect(described_class.age(test_key, 3600)).to be_nil
      end

      it 'returns nil for nil ttl' do
        allow(mock_redis).to receive(:ttl).with(test_key).and_return(nil)
        expect(described_class.age(test_key, 3600)).to be_nil
      end
    end
  end

  describe '#fetch' do
    let(:service) { described_class.new(key: test_key, ttl: test_ttl) }

    context 'when cache hit' do
      before do
        allow(mock_redis).to receive(:get).with(test_key).and_return(test_value_json)
      end

      it 'returns parsed json data' do
        result = service.fetch
        expect(result).to eq(test_value)
      end

      it 'does not yield the block' do
        expect { |b| service.fetch(&b) }.not_to yield_control
      end
    end

    context 'when cache miss' do
      before do
        allow(mock_redis).to receive(:get).with(test_key).and_return(nil)
        allow(mock_redis).to receive(:set).with(test_key, test_value_json, ex: test_ttl).and_return('OK')
      end

      it 'yields the block and caches the result' do
        expect(mock_redis).to receive(:set).with(test_key, test_value_json, ex: test_ttl)

        result = service.fetch { test_value }
        expect(result).to eq(test_value)
      end
    end

    context 'when cached value is not valid json' do
      let(:invalid_json) { 'invalid json' }

      before do
        allow(mock_redis).to receive(:get).with(test_key).and_return(invalid_json)
      end

      it 'returns raw value' do
        result = service.fetch
        expect(result).to eq(invalid_json)
      end
    end
  end

  describe 'private methods' do
    let(:service) { described_class.new(key: test_key, ttl: test_ttl) }

    describe '#get' do
      it 'retrieves value from redis' do
        expect(mock_redis).to receive(:get).with(test_key)
        service.send(:get)
      end
    end

    describe '#set' do
      it 'stores value in redis with ttl' do
        expect(mock_redis).to receive(:set).with(test_key, test_value_json, ex: test_ttl)
        service.send(:set, test_value)
      end
    end

    describe '#ttl' do
      it 'retrieves ttl from redis' do
        expect(mock_redis).to receive(:ttl).with(test_key)
        service.send(:ttl)
      end
    end

    describe '#key_exists?' do
      it 'checks key existence in redis' do
        expect(mock_redis).to receive(:exists?).with(test_key)
        service.send(:key_exists?)
      end
    end
  end
end
