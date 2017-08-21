require 'bundler/setup'
require 'simple_jsonapi_client'
require 'pry'
require 'jsonapi_app_client'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after(:suite) do
    connection = JSONAPIAppClient.new.connection
    response = connection.post('/database_cleanings')
  end
end
