require 'database_cleaner'

class DatabaseCleaningsController < ApplicationController
  def create
    DatabaseCleaner.clean_with(:truncation, except: %w(ar_internal_metadata))
    head :no_content
  end
end
