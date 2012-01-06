require "bundler/gem_tasks"
require 'rake/testtask'
require 'rspec'
require 'rspec/core/rake_task'


task :default => :spec
task :test => :spec

RSpec::Core::RakeTask.new(:spec) do
  system "echo \"recreating database \" && cd #{File.join(File.dirname(__FILE__), 'spec', 'app')} && rake db:migrate:reset"
end 