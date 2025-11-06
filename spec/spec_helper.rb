# frozen_string_literal: true

# SimpleCov must be started before any application code is loaded
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/'

    add_group 'CLI', 'lib/pocket_knife/cli.rb'
    add_group 'Calculator', 'lib/pocket_knife/calculator.rb'
    add_group 'Models', 'lib/pocket_knife/calculation_'
    add_group 'LLM', ['lib/pocket_knife/llm_config.rb', 'lib/pocket_knife/percentage_calculator_tool.rb']
    add_group 'Storage', 'lib/pocket_knife/storage/'

    # 75%+ coverage is acceptable given optional features (LLM, Storage)
    # Some error paths (network errors, API timeouts, file permissions) are difficult to test
    # without complex mocking or live API calls
    # Storage integration tests will be added in next phase
    minimum_coverage 75
  end
end

require_relative '../lib/pocket_knife'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Use the expect syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Show slow tests
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies
  config.order = :random
  Kernel.srand config.seed
end
