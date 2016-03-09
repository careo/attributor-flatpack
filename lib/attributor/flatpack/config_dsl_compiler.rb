module Attributor
  module Flatpack
    class ConfigDSLCompiler < Attributor::HashDSLCompiler
      def key(name, attr_type = nil, **opts, &block)
        native_key = options.fetch(:key_type, Attributor::Object).native_type
        unless name.is_a?(native_key)
          raise ArgumentError, "Invalid key: #{name.inspect}, " \
                               "must be instance of #{native_key}"
        end
        attr_type = Attributor::Flatpack::Config if attr_type.nil? && block
        target.keys[name] = define(name, attr_type, **opts, &block)
      end
    end
  end
end
