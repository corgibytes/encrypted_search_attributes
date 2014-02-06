require 'spec_helper'

db_config_file = File.expand_path('../../config/database.yml', __FILE__)
encryption_config_file = File.expand_path('../../config/symmetric-encryption.yml', __FILE__)

ActiveRecord::Base.configurations = YAML::load(ERB.new(IO.read(db_config_file)).result)
ActiveRecord::Base.establish_connection('test')

ActiveRecord::Schema.define(version: 0) do
  create_table :widgets, force: true do |t|
    t.string :encrypted_name
    t.string :encrypted_search_name
  end
end

class Widget < ActiveRecord::Base
  attr_encrypted        :name
  attr_encrypted_search :name
end

SymmetricEncryption.load!(encryption_config_file, 'test')

# Initialize the database connection
config = YAML.load(ERB.new(File.new(db_config_file).read).result)['test']

Widget.establish_connection(config)

describe 'attr_encrypted_search' do
  it 'sets encrypted search field on initialization' do
    widget = Widget.new(name: 'Test Value')

    search_value = ::SymmetricEncryption.encrypt('test value')
    expect(widget.encrypted_search_name).to eq(search_value)

    widget.save!
    expect(widget.encrypted_search_name).to eq(search_value)

    widget.reload
    expect(widget.encrypted_search_name).to eq(search_value)
  end

  it 'sets the encrypted search field on creation' do
    widget = Widget.create!(name: 'Another Test')

    search_value = ::SymmetricEncryption.encrypt('another test')
    expect(widget.encrypted_search_name).to eq(search_value)

    widget.reload
    expect(widget.encrypted_search_name).to eq(search_value)
  end

  it 'sets encrypted search field on assignment' do
    widget = Widget.create!

    widget.name = 'Something Else'

    search_value = ::SymmetricEncryption.encrypt('something else')
    expect(widget.encrypted_search_name).to eq(search_value)

    widget.save!
    expect(widget.encrypted_search_name).to eq(search_value)

    widget.reload
    expect(widget.encrypted_search_name).to eq(search_value)
  end

  it 'preserves attr_encrypted functionality' do
    widget = Widget.create!(name: 'Anything')
    expect(widget.name).to eq('Anything')
    expect(widget.encrypted_name).to eq(::SymmetricEncryption.encrypt('Anything'))

    widget.reload
    expect(widget.encrypted_name).to eq(::SymmetricEncryption.encrypt('Anything'))
  end
end
