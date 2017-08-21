require 'database_cleaner'

class DatabaseCleaningsController < ApplicationController
  def create
    DatabaseCleaner.clean_with(:truncation)
    head :no_content
  end
end
