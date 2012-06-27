$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'dm-parse'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

app_id  = "ydJFDnkvq78QxiKfSt7HR52pD2Ax8mixJ7bE948o"
api_key = "WDl0xpJYXtfwMnknOuv4CnZ1wTrBXQiDdOIaioJQ"
DataMapper.setup :default, adapter: :parse, app_id: app_id, api_key: api_key

class Article
  include DataMapper::Resource

  is :parse

  property :title,      String
  property :body,       Text
  property :rank,       Integer
  property :closed_at,  ParseDate

  has n, :comments
end

class Comment
  include DataMapper::Resource

  is :parse

  property :body,       Text

  belongs_to :article
end

DataMapper.finalize

