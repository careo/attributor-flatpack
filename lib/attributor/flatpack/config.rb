module Attributor
  module Flatpack
    class Config < Attributor::Hash
      @key_type = Symbol
      @value_attribute = Attribute.new(@value_type)

      def self.inherited(klass)
        super
        klass.options[:dsl_compiler] = ConfigDSLCompiler
      end

      def self.from_hash(object,context, recurse: false)
        config = self.new(object)
        config
      end

      def initialize(data = nil)
        @raw = data
        @loaded = {}
      end

      def respond_to_missing?(name,*)
        attribute_name = name.to_s
        attribute_name.chomp!('=')

        return true if self.class.attributes.key?(attribute_name.to_sym)
        super
      end

      def method_missing(name, *args)
        attribute_name = name.to_s
        attribute_name.chomp!('=')

        sym = attribute_name.to_sym

        if self.class.attributes.key?(sym)
          self.define_accessors(sym)
          return self.__send__(name, *args)
        end

        super
      end

      def define_accessors(name)
        self.define_reader(name)
        self.define_writer(name)
      end

      def define_reader(name)
        define_singleton_method(name) do
          self.get(name)
        end
      end

      def define_writer(name)
        context = ["assignment","of(#{name})"].freeze
        define_singleton_method(name.to_s + "=") do |value|
          self.set(name, value, context: context)
        end
      end

      def get(key, context: self.generate_subcontext(Attributor::DEFAULT_ROOT_CONTEXT,key))
        @loaded[key] ||= begin
          unless (attribute = self.class.keys[key])
            raise LoadError, "Undefined key received: #{key.inspect} for #{Attributor.humanize_context(context)}"
          end


          value = fetch(key) do
            if attribute.type < Attributor::Flatpack::Config
              self.subselect(key)
            else
              raise "couldn't find #{key.inspect} anywhere"
            end
          end

          attribute.load(value, context)
        end

      end

      # search @raw for key
      def fetch(key)
        return @raw[key] if @raw.key?(key)

        _found_key, found_value = @raw.find do |(k,_v)|
          case k
          when ::Symbol
            k.to_s.downcase == key.to_s.downcase
          when ::String
            key.to_s.downcase == k.downcase
          else
            p 'dunno what this is'
            false
          end
        end

        return found_value if found_value

        yield if block_given?
      end

      def subselect(prefix)
        prefix_match = /^#{prefix.to_s}_?(.*)/i

        selected = @raw.collect do |(k,v)|
          if (match = prefix_match.match(k))
            [match[1],v]
          end
        end.compact
        ::Hash[selected]
      end

      def [](k)
        self.get k
      end

      def []=(k,v)
        self.set k, v
      end

    end
  end
end
