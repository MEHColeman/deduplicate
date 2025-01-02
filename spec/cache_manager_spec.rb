require 'rspec'
require_relative '../lib/cache_manager'

RSpec.describe CacheManager do
  let(:cache_file) { 'test_cache.json' }
  let(:cache_manager) { CacheManager.new(cache_file, 2) } # Save interval set to 2 for testing

  after do
    File.delete(cache_file) if File.exist?(cache_file)
  end

  describe '#load_cache' do
    it 'loads an empty cache if the file does not exist' do
      expect(cache_manager.cache).to eq({})
    end

    it 'loads the cache from a file' do
      File.write(cache_file, { 'key' => 'value' }.to_json)
      expect(cache_manager.cache).to eq({ 'key' => 'value' })
    end
  end

  describe '#save_cache' do
    it 'saves the cache to a file' do
      cache_manager.store('key', 'value') # Store ensures the save interval is handled
      cache_manager.save_cache # Explicitly call save_cache to ensure the file is written
      expect(File.exist?(cache_file)).to be true
      expect(JSON.parse(File.read(cache_file))).to eq({ 'key' => 'value' })
    end
  end

  describe '#store' do
    it 'stores a value and saves cache after reaching save interval' do
      cache_manager.store('key1', 'value1')
      expect(File.exist?(cache_file)).to be false

      cache_manager.store('key2', 'value2')
      expect(File.exist?(cache_file)).to be true
      expect(JSON.parse(File.read(cache_file))).to eq({ 'key1' => 'value1', 'key2' => 'value2' })
    end
  end

  describe '#fetch' do
    it 'retrieves a stored value' do
      cache_manager.store('key', 'value')
      expect(cache_manager.fetch('key')).to eq('value')
    end

    it 'returns nil for missing keys' do
      expect(cache_manager.fetch('missing_key')).to be_nil
    end
  end

  describe '#delete' do
    it 'removes a key from the cache' do
      cache_manager.store('key', 'value')
      cache_manager.delete('key')
      expect(cache_manager.fetch('key')).to be_nil
    end
  end
end
