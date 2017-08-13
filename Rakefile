require "bundler/gem_tasks"
require "rspec/core/rake_task"

task :spec do
  exec('docker-compose run spec')
end

task :default => :spec
