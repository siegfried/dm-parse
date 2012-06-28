$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'dm-parse'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

# To run the tests, setup a Parse environment in "parse_env.yml"
# under the same directory, which I don't provide.
env_file    = File.join(File.dirname(__FILE__), "parse_env.yml")
settings    = YAML::load(File.read env_file)
app_id      = settings["app_id"]
api_key     = settings["api_key"]
master_key  = settings["master_key"]

raise "You must setup a parse environment before testing" unless app_id && api_key && master_key

DataMapper.setup :default,  adapter: :parse, app_id: app_id, api_key: api_key
DataMapper.setup :master,   adapter: :parse, app_id: app_id, api_key: master_key, master: true

class User
  include DataMapper::Resource

  is :parse_user
  storage_names[:master] = "_User"
  property :location, ParseGeoPoint
end

class Article
  include DataMapper::Resource

  is :parse

  property :title,      String
  property :body,       Text
  property :rank,       Integer
  property :closed_at,  ParseDate
  property :attachment, ParseFile

  has n, :comments
end

class Comment
  include DataMapper::Resource

  is :parse

  property :body,       Text

  belongs_to :article
end

DataMapper.finalize

