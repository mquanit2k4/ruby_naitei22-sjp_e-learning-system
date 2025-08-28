require "simplecov"

SimpleCov.start do
  track_files "app/controllers/user/*.rb"
  add_filter do |src|
    !src.filename.match?(/app\/controllers\/user\/.*\.rb$/)
  end
  minimum_coverage 90
  minimum_coverage_by_file 90
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
