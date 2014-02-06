# EncryptedSearchAttributes

Auto populates encrypted fields that are designed for searching

Encrypting a field makes it very difficult to perform a case insensitive search for the columns data. This gem normalizes the text before encrypted it and storing it in a search column. The current normalization method is to convert the text to all lowercase.

This gem is intended to be used with the symmetric-encryption gem. It assumes that a `encrypted_search_attribute` column exists for the encrypted attribute.

## Example

Let's assume we have the following ActiveRecord model defined.

```ruby
class Widget < ActiveRecord::Base
  attr_encrypted        :name
  attr_encrypted_search :name
end
```

This would require the database schema to look something like this.

```ruby
  create_table "patients", :force => true do |t|
    t.string "encrypted_name"
    t.string "encrypted_search_name"
  end
```

## Installation

Add this line to your application's Gemfile:

    gem 'encrypted_search_attributes'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install encrypted_search_attributes

## Contributing

1. Fork it ( http://github.com/corgibytes/encrypted_search_attributes/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
