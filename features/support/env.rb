# Compose sets RAILS_ENV=development. The suite always uses the test database.
ENV["RAILS_ENV"] = "test"

require "cucumber/rails"
require "rspec/expectations"

World(RSpec::Matchers)
World(Rack::Test::Methods)

module RackTestApp
  def app
    Rails.application
  end
end

World(RackTestApp)

# A missing route must come back as a response so the Then steps can reject it.
ActionController::Base.allow_rescue = true

Cucumber::Rails::Database.autorun_database_cleaner = false

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
