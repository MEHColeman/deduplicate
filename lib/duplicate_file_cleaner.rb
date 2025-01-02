require 'digest'
require 'fileutils'
require 'json'
require 'find'

class DuplicateFileCleaner
  def initialize(cache_manager)
    @cache_manager = cache_manager
    @seen_files = {}
    @size_to_files = {}
    @hashed_files = {}
    @save_counter = 0
  end

  def file_hash(file_path)
    hash = @cache_manager.fetch(file_path)
    return hash if hash && File.exist?(file_path)

    hash = Digest::SHA256.file(file_path).hexdigest
    @cache_manager.store(file_path, hash)
    hash
  end

  def process_duplicates(directories, dry_run, verbose)
    directories.each do |dir|
      Find.find(dir) do |file_path|
        next unless File.file?(file_path)

        process_file(file_path, dry_run, verbose)
      end
    end
    @cache_manager.save_cache
  end

  def process_file(file_path, dry_run, verbose)
    @save_counter += 1
    print_status(file_path, @save_counter) if verbose

    file_size = File.size(file_path)
    @size_to_files[file_size] ||= []
    @size_to_files[file_size] << file_path

    if @size_to_files[file_size].size > 1
      hash_all_files_of_same_size(file_size, dry_run)
    else
      identifier = file_identifier(file_path)
      @seen_files[identifier] = true
    end
  end

  def hash_all_files_of_same_size(file_size, dry_run)
    puts "Hashing all files of size #{file_size}"
    @size_to_files[file_size].each do |f_path|
      next if @hashed_files[f_path]

      identifier = file_identifier(f_path)
      next if @seen_files.key?(identifier)

      hash = file_hash(f_path)
      @hashed_files[f_path] = hash

      if @seen_files.value?(hash)
        handle_duplicate(f_path, hash, dry_run)
      else
        @seen_files[identifier] = hash
      end
    end
  end

  def handle_duplicate(file_path, hash, dry_run)
    original_file = @seen_files.key(hash)
    identifier = file_identifier(file_path)
    puts "\nDuplicate found: #{file_path} (original: #{original_file}, unique ID: #{identifier})"
    if dry_run
      puts "  Dry run: Would delete #{file_path}"
    else
      FileUtils.rm(file_path)
      puts "  Deleted: #{file_path}"
    end
  end

  def file_identifier(file_path)
    stat = File.stat(file_path)
    "#{stat.dev}-#{stat.ino}"
  end

  def print_status(file_path, count)
    print "Processing file #{count}: #{file_path}\r"
    $stdout.flush
  end
end

