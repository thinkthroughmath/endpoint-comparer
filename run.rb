#!/usr/bin/env ruby

require 'yaml'
require 'httparty'
require 'diffy'

ENDPOINTS_FILE='endpoints.txt'
PROPERTIES_FILE='test.yaml'
RESULTS_DIR='results'

def read_file file
  File.readlines(file)
    .map {|r| r.strip }
    .reject {|r| r.empty?}
    .reject {|r| r.start_with?('#')}
end

def cleanup_results
  FileUtils.rm_rf(RESULTS_DIR)
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
  url = "#{server['url']}#{endpoint}"
  puts "hitting #{url}"
  HTTParty.get(url,{
    query: endpoint,
    headers: server['headers']
  })
end

def write_data filename, data
  File.open(filename, 'a') do |file|
    file.write(data)
  end
end

def write_diff endpoint, diff
  FileUtils.mkdir_p "results"
  data = "#{endpoint}\n\n#{diff}\n"
  write_data "#{RESULTS_DIR}/results.diff", data
end

def compare_url endpoint, properties
  control = get(properties['control'],endpoint)
  experiment = get(properties['experiment'],endpoint)

  diff = Diffy::Diff.new(control, experiment)

  if diff.to_s != ""
    puts "difference found"
    write_diff endpoint, diff
  elsif control.nil? and experiment.nil? or control.empty? and experiment.empty?
    write_diff endpoint, "Nil or blanks detected"
  end
rescue Exception => e
  puts "Error hitting endpoint: #{endpoint}"
  puts e.message
end

def execute_against_urls endpoints, properties
  endpoints.each do |endpoint|
    compare_url endpoint, properties
  end
end

## Main

cleanup_results
properties = read_properties
endpoints = read_file(ENDPOINTS_FILE)
execute_against_urls(endpoints, properties)
