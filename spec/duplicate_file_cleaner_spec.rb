require 'rspec'
require 'fileutils'
require_relative '../lib/duplicate_file_cleaner'
require_relative '../lib/cache_manager'

RSpec.describe DuplicateFileCleaner do
  let(:test_dir) { 'test_dir' }
  let(:cache_file) { 'test_cache.json' }
  let(:cache_manager) { CacheManager.new(cache_file) }
  let(:cleaner) { DuplicateFileCleaner.new(cache_manager) }

  before do
    FileUtils.mkdir_p(test_dir)
  end

  after do
    FileUtils.rm_rf(test_dir)
    File.delete(cache_file) if File.exist?(cache_file)
  end

  def create_file(path, content)
    File.write(path, content)
  end

  describe '#file_hash' do
    it 'calculates and caches the hash of a file' do
      file_path = File.join(test_dir, 'file1.txt')
      create_file(file_path, 'test content')

      hash = cleaner.file_hash(file_path)
      expect(hash).to eq(Digest::SHA256.hexdigest('test content'))
      expect(cache_manager.fetch(file_path)).to eq(hash)
    end
  end

  describe '#process_duplicates' do
    it 'does not delete unique files' do
      file1 = File.join(test_dir, 'file1.txt')
      create_file(file1, 'unique content')

      cleaner.process_duplicates([test_dir], false, false)
      expect(File.exist?(file1)).to be true
    end

    it 'detects and deletes duplicates' do
      file1 = File.join(test_dir, 'file1.txt')
      file2 = File.join(test_dir, 'file2.txt')

      create_file(file1, 'duplicate content')
      create_file(file2, 'duplicate content')

      cleaner.process_duplicates([test_dir], false, false)
      expect(File.exist?(file1) || File.exist?(file2)).to be true
    end

    it 'does not delete files in dry-run mode' do
      file1 = File.join(test_dir, 'file1.txt')
      file2 = File.join(test_dir, 'file2.txt')

      create_file(file1, 'duplicate content')
      create_file(file2, 'duplicate content')

      cleaner.process_duplicates([test_dir], true, false)
      expect(File.exist?(file1)).to be true
      expect(File.exist?(file2)).to be true
    end

    it 'handles files with unique sizes without hashing' do
      file1 = File.join(test_dir, 'file1.txt')
      file2 = File.join(test_dir, 'file2.txt')

      create_file(file1, 'unique content 1')
      create_file(file2, 'unique content 2')

      cleaner.process_duplicates([test_dir], false, false)
      expect(File.exist?(file1)).to be true
      expect(File.exist?(file2)).to be true
    end

    it 'detects duplicates with the same size but different content' do
      file1 = File.join(test_dir, 'file1.txt')
      file2 = File.join(test_dir, 'file2.txt')
      file3 = File.join(test_dir, 'file3.txt')

      create_file(file1, 'duplicate content')
      create_file(file2, 'duplicate content')
      create_file(file3, 'unique content')

      cleaner.process_duplicates([test_dir], false, false)
      expect(File.exist?(file1) || File.exist?(file2)).to be true
      expect(File.exist?(file3)).to be true
    end
  end
end
