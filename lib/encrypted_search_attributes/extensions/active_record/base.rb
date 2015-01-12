module ActiveRecord
  class Base
    class << self
      def attr_encrypted_search(*params)
        define_attribute_methods rescue nil

        options = params.last.is_a?(Hash) ? params.pop.dup : {}
        compress = options.delete(:compress) || false
        type = options.delete(:type) || :string
        normalize = options.delete(:normalize)

        raise "Invalid type: #{type.inspect}. Valid types: #{SymmetricEncryption::COERCION_TYPES.inspect}" unless SymmetricEncryption::COERCION_TYPES.include?(type)

        options.each {|option| warn "Ignoring unknown option #{option.inspect} supplied to attr_encrypted_search with #{params.inspect}"}

        if const_defined?(:EncryptedSearchAttributes, _search_ancestors = false)
          mod = const_get(:EncryptedSearchAttributes)
        else
          mod = const_set(:EncryptedSearchAttributes, Module.new)
          include mod
        end

        params.each do |attribute|
          mod.module_eval do
            define_method("#{attribute}=") do |value|
              if value
                send(
                  "encrypted_search_#{attribute}=",
                  ::SymmetricEncryption.encrypt(
                    send("normalize_#{attribute}", value),
                    false,
                    compress,
                    type
                  )
                )
              end
              super(value)
            end

            define_method("normalize_#{attribute}") do |value|
              if normalize
                if normalize.respond_to?(:call)
                  normalize.call(value)
                else
                  send(normalize, value)
                end
              else
                value.downcase
              end
            end
          end
        end

      end
    end
  end
end
