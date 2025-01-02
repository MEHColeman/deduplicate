require 'yaml'

class ConfigLoader
  def self.load_directories_from_yaml(yaml_file)
    unless File.exist?(yaml_file)
      puts "YAML file not found: #{yaml_file}"
      exit 1
    end

    begin
      puts "YAML.load_file"
      data = YAML.load_file(yaml_file)
      directories = data['directories']

      if directories.nil? || !directories.is_a?(Array) || directories.empty?
        puts "YAML file must contain a 'directories' key with a non-empty array."
        exit 1
      end

      directories
    rescue StandardError => e
      puts "Failed to parse YAML file: #{e.message}"
      exit 1
    end
  end
end
