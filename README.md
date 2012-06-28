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

To define model for parse, use `is :parse`:

```ruby
class Article
  include DataMapper::Resource

  is :parse # it defines id, created_at and updated_at for you

  property :title,      String
  property :body,       Text
  property :rank,       Integer
  property :closed_at,  ParseDate # Date type for Parse

  has n, :comments
end

class Comment
  include DataMapper::Resource

  is :parse

  property :body,       Text

  belongs_to :article
end
```

To define a user model, use `is :parse_user`:

```ruby
class User
  include DataMapper::Resource

  # more than :parse, it also defines username, password and email.
  # it also set the default storage_names to "_User"
  is :parse_user
  storage_names[:master] = "_User"
end
```

By this, you can use `User.authenticate(username, password)` to sign in, and use `User.request_password_reset(email)` to reset password.

## Copyright

See LICENSE.
