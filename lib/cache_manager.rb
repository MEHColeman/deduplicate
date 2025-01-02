require 'json'

class CacheManager
  attr_reader :cache

  def initialize(cache_file, save_interval = 100)
    @cache_file = cache_file
    @save_interval = save_interval
    @cache = load_cache
    @operation_counter = 0
  end

  def load_cache
    if File.exist?(@cache_file)
      puts "Parsing cache JSON"
      JSON.parse(File.read(@cache_file))
    else
      {}
    end
  end

  def save_cache
    File.write(@cache_file, JSON.pretty_generate(@cache))
  end

  def store(key, value)
    @cache[key] = value
    @operation_counter += 1
    save_cache if @operation_counter % @save_interval == 0
  end

  def fetch(key)
    @cache[key]
  end

  def delete(key)
    @cache.delete(key)
  end
end
