require 'rspec'
require 'fileutils'
require_relative '../lib/config_loader'

RSpec.describe ConfigLoader do
  let(:yaml_file) { 'test_config.yaml' }

  after do
    File.delete(yaml_file) if File.exist?(yaml_file)
  end

  it 'loads directories from a valid YAML file' do
    File.write(yaml_file, { 'directories' => ['/path/to/dir'] }.to_yaml)
    directories = ConfigLoader.load_directories_from_yaml(yaml_file)
    expect(directories).to eq(['/path/to/dir'])
  end

  it 'raises an error for an invalid YAML file' do
    File.write(yaml_file, 'invalid: [this is not valid YAML')
    expect { ConfigLoader.load_directories_from_yaml(yaml_file) }.to raise_error(SystemExit)
  end

  it 'raises an error for missing directories key' do
    File.write(yaml_file, { 'invalid_key' => [] }.to_yaml)
    expect { ConfigLoader.load_directories_from_yaml(yaml_file) }.to raise_error(SystemExit)
  end
end
