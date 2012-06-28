# dm-parse

A DataMapper extension for [Parse](https://parse.com/), include an adapter and some types for Parse.

## Installation

Include in your `Gemfile`:

```ruby
gem "dm-parse"
```

Or just gem install:

```bash
gem install dm-parse
```

## Usage

To setup the adapter:

```ruby
DataMapper.setup(:default, adapter: :parse, app_id: "your-id", api_key: "your-rest-api-key")
```

To setup with Master Key:

```ruby
DataMapper.setup(:default, adapter: :parse, app_id: "your-id", api_key: "your-master-key", master: true)
```

Then have fun with DataMapper.

## Copyright

See LICENSE.
