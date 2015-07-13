#!/usr/bin/env ruby

require 'yaml'
require 'httparty'
require 'diffy'

ENDPOINTS_FILE='endpoints.txt'
PROPERTIES_FILE='test.yaml'

def read_file file
  File.readlines(file)
    .map {|r| r.strip }
    .reject {|r| r.empty?}
    .reject {|r| r.start_with?('#')}
end

def read_properties
  YAML.load(File.read(PROPERTIES_FILE))
end

def log_with_timing(section_name)
  start_time = Time.now
  puts "\n--- Starting #{section_name} at #{start_time} ---"
  value = yield
  end_time = Time.now
  puts "--- Finished #{section_name} at #{end_time}, took #{end_time - start_time} seconds ---\n"
  value
end

def get server, endpoint
    HTTParty.get("#{server['url']}#{endpoint}",{
      query: endpoint,
      headers: server['headers']
    })
end

def write_data filename, data
  File.open(filename, 'w') do |file|
    file.write(data)
  end
end

def write_diff endpoint, diff
  FileUtils.mkdir_p "results"
  data = "#{endpoint}\n\n#{diff}\n"
  write_data 'results/results.diff', data
end

def execute_against_urls endpoints, properties

  endpoints.each do |endpoint|
    control = get(properties['control'],endpoint)
    experiment = get(properties['experiment'],endpoint)
    experiment = "foo"
    diff = Diffy::Diff.new(control, experiment)
    if diff.to_s != ""
      write_diff endpoint, diff
    end
  end

end

## Main

properties = read_properties
endpoints = read_file(ENDPOINTS_FILE)
execute_against_urls(endpoints, properties)
