#!/bin/env ruby

def log_with_timing(section_name)
  start_time = Time.now
  Rails.logger.info "\n--- Starting #{section_name} at #{start_time} ---"
  yield
  end_time = Time.now
  Rails.logger.info "--- Finished #{section_name} at #{end_time}, took #{end_time - start_time} seconds ---\n"
end

def read_endpoints
end

## Main

read_endpoints
execute
