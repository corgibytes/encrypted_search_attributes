require 'spec_helper'

db_config_file = File.expand_path('../../config/database.yml', __FILE__)
encryption_config_file = File.expand_path('../../config/symmetric-encryption.yml', __FILE__)

ActiveRecord::Base.configurations = YAML::load(ERB.new(IO.read(db_config_file)).result)
ActiveRecord::Base.establish_connection('test')

ActiveRecord::Schema.define(version: 0) do
  create_table :widget_with_custom_methods, force: true do |t|
    t.string :encrypted_name
    t.string :encrypted_search_name
  end
end

class WidgetWithCustomMethod < ActiveRecord::Base
  attr_encrypted        :name
  attr_encrypted_search :name,
                        normalize: :downcase_no_spaces

  private

  def downcase_no_spaces(value)
    value.downcase.gsub(' ', '')
  end
end

SymmetricEncryption.load!(encryption_config_file, 'test')

# Initialize the database connection
config = YAML.load(ERB.new(File.new(db_config_file).read).result)['test']

WidgetWithCustomMethod.establish_connection(config)

describe 'custom method attr_encrypted_search' do
  it 'sets encrypted search field on initialization' do
    widget = WidgetWithCustomMethod.new(name: 'Test Value')

    search_value = ::SymmetricEncryption.encrypt('testvalue')
    expect(widget.encrypted_search_name).to eq(search_value)

    widget.save!
    expect(widget.encrypted_search_name).to eq(search_value)

    widget.reload
    expect(widget.encrypted_search_name).to eq(search_value)
  end

  it 'sets the encrypted search field on creation' do
    widget = WidgetWithCustomMethod.create!(name: 'Another Test')

    search_value = ::SymmetricEncryption.encrypt('anothertest')
    expect(widget.encrypted_search_name).to eq(search_value)

    widget.reload
    expect(widget.encrypted_search_name).to eq(search_value)
  end

  it 'correctly handles nil values' do
    widget = WidgetWithCustomMethod.create!(name: nil)

    expect(widget.encrypted_search_name).to eq(nil)

    widget.reload
    expect(widget.encrypted_search_name).to eq(nil)
  end

  it 'sets encrypted search field on assignment' do
    widget = WidgetWithCustomMethod.create!

    widget.name = 'Something Else'

    search_value = ::SymmetricEncryption.encrypt('somethingelse')
    expect(widget.encrypted_search_name).to eq(search_value)

    widget.save!
    expect(widget.encrypted_search_name).to eq(search_value)

    widget.reload
    expect(widget.encrypted_search_name).to eq(search_value)
  end

  it 'preserves attr_encrypted functionality' do
    widget = WidgetWithCustomMethod.create!(name: 'Anything')
    expect(widget.name).to eq('Anything')
    expect(widget.encrypted_name).to eq(::SymmetricEncryption.encrypt('Anything'))

    widget.reload
    expect(widget.encrypted_name).to eq(::SymmetricEncryption.encrypt('Anything'))
  end
end
