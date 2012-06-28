# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "dm-parse"
  gem.homepage = "https://github.com/siegfried/dm-parse"
  gem.license = "MIT"
  gem.summary = %Q{An extension to make DataMapper working on Parse.com}
  gem.description = %Q{An extension to make DataMapper working on Parse.com}
  gem.email = "zhiqiang.lei@gmail.com"
  gem.authors = ["Zhi-Qiang Lei"]
  # dependencies defined in Gemfile
  gem.add_dependency "dm-core", ">= 1.2"
  gem.add_dependency "dm-validations", ">= 1.2"
  gem.add_dependency "activesupport", ">= 3.2"
  gem.add_dependency "nestful", ">= 0.0.8"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
