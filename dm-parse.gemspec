# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "dm-parse"
  s.version = "0.3.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Zhi-Qiang Lei"]
  s.date = "2012-07-06"
  s.description = "An extension to make DataMapper working on Parse.com"
  s.email = "zhiqiang.lei@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "dm-parse.gemspec",
    "lib/adapters/parse/engine.rb",
    "lib/adapters/parse/query.rb",
    "lib/adapters/parse_adapter.rb",
    "lib/collection.rb",
    "lib/dm-parse.rb",
    "lib/is/parse.rb",
    "lib/property/parse_date.rb",
    "lib/property/parse_file.rb",
    "lib/property/parse_geo_point.rb",
    "lib/property/parse_key.rb",
    "lib/property/parse_pointer.rb",
    "lib/property/text.rb",
    "spec/integration_spec.rb",
    "spec/parse_adapter_spec.rb",
    "spec/parse_date_spec.rb",
    "spec/parse_file_spec.rb",
    "spec/parse_geo_point_spec.rb",
    "spec/parse_key_spec.rb",
    "spec/parse_pointer_spec.rb",
    "spec/query_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "https://github.com/siegfried/dm-parse"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "An extension to make DataMapper working on Parse.com"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, [">= 1.2"])
      s.add_runtime_dependency(%q<dm-validations>, [">= 1.2"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.2"])
      s.add_runtime_dependency(%q<parse-ruby-client>, [">= 0.0.8"])
      s.add_development_dependency(%q<rspec>, [">= 2.10.0"])
      s.add_development_dependency(%q<yard>, [">= 0.7"])
      s.add_development_dependency(%q<rdoc>, [">= 3.12"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_development_dependency(%q<jeweler>, [">= 1.8.3"])
      s.add_development_dependency(%q<simplecov>, [">= 0.6"])
      s.add_development_dependency(%q<debugger>, [">= 1.1"])
      s.add_development_dependency(%q<pry>, [">= 0.9"])
    else
      s.add_dependency(%q<dm-core>, [">= 1.2"])
      s.add_dependency(%q<dm-validations>, [">= 1.2"])
      s.add_dependency(%q<activesupport>, [">= 3.2"])
      s.add_dependency(%q<parse-ruby-client>, [">= 0.0.8"])
      s.add_dependency(%q<rspec>, [">= 2.10.0"])
      s.add_dependency(%q<yard>, [">= 0.7"])
      s.add_dependency(%q<rdoc>, [">= 3.12"])
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_dependency(%q<jeweler>, [">= 1.8.3"])
      s.add_dependency(%q<simplecov>, [">= 0.6"])
      s.add_dependency(%q<debugger>, [">= 1.1"])
      s.add_dependency(%q<pry>, [">= 0.9"])
    end
  else
    s.add_dependency(%q<dm-core>, [">= 1.2"])
    s.add_dependency(%q<dm-validations>, [">= 1.2"])
    s.add_dependency(%q<activesupport>, [">= 3.2"])
    s.add_dependency(%q<parse-ruby-client>, [">= 0.0.8"])
    s.add_dependency(%q<rspec>, [">= 2.10.0"])
    s.add_dependency(%q<yard>, [">= 0.7"])
    s.add_dependency(%q<rdoc>, [">= 3.12"])
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
    s.add_dependency(%q<jeweler>, [">= 1.8.3"])
    s.add_dependency(%q<simplecov>, [">= 0.6"])
    s.add_dependency(%q<debugger>, [">= 1.1"])
    s.add_dependency(%q<pry>, [">= 0.9"])
  end
end

