module ActiveRecord
  class Base
    class << self
      def attr_encrypted_search(*params)
        define_attribute_methods rescue nil

        options   = params.last.is_a?(Hash) ? params.pop.dup : {}
        compress  = options.delete(:compress) || false
        type      = options.delete(:type) || :string

        raise "Invalid type: #{type.inspect}. Valid types: #{SymmetricEncryption::COERCION_TYPES.inspect}" unless SymmetricEncryption::COERCION_TYPES.include?(type)

        options.each {|option| warn "Ignoring unknown option #{option.inspect} supplied to attr_encrypted_search with #{params.inspect}"}

        if const_defined?(:EncryptedSearchAttributes, _search_ancestors = false)
          mod = const_get(:EncryptedSearchAttributes)
        else
          mod = const_set(:EncryptedSearchAttributes, Module.new)
          include mod
        end

        params.each do |attribute|
          mod.module_eval(<<-ENCRYPTEDSEARCH, __FILE__, __LINE__ + 1)
            def #{attribute}=(value)
              if value
                self.encrypted_search_#{attribute} = ::SymmetricEncryption.encrypt(value.downcase,false,#{compress},:#{type})
              end
              super(value)
            end
          ENCRYPTEDSEARCH
        end

      end
    end
  end
end
