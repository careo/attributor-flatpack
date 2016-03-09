module Attributor
  module Flatpack
    class ConfigDSLCompiler < Attributor::HashDSLCompiler
      def key(name, attr_type=nil, **opts, &block)
        unless name.kind_of?(options.fetch(:key_type, Attributor::Object).native_type)
          raise "Invalid key: #{name.inspect}, must be instance of #{options[:key_type].native_type.name}"
        end
        if attr_type.nil? && block
          attr_type = Attributor::Flatpack::Config
        end
        target.keys[name] = define(name, attr_type, **opts, &block)
      end
    end
  end
end
