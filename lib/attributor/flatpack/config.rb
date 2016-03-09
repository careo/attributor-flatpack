module Attributor
  module Flatpack
    class Config < Attributor::Hash
      @key_type = Symbol

      def self.inherited(klass)
        super
        klass.options[:dsl_compiler] = ConfigDSLCompiler
      end

      def self.from_hash(object, _context, **_opts)
        config = new(object)
        config
      end

      def initialize(data = nil)
        @raw = data
        @contents = {}
      end

      def respond_to_missing?(name, *)
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
          define_accessors(sym)
          return __send__(name, *args)
        end

        super
      end

      def define_accessors(name)
        define_reader(name)
        define_writer(name)
      end

      def define_reader(name)
        define_singleton_method(name) do
          get(name)
        end
      end

      def define_writer(name)
        context = ['assignment', "of(#{name})"].freeze
        define_singleton_method(name.to_s + '=') do |value|
          set(name, value, context: context)
        end
      end

      def default_context(key)
        generate_subcontext(Attributor::DEFAULT_ROOT_CONTEXT, key)
      end

      def get(key, context: default_context(key))
        unless (attribute = self.class.keys[key])
          raise UndefinedKey, key, context
        end

        @contents[key] ||= _get(key, attribute: attribute, context: context)
      end

      def _get(key, attribute:, context:)
        if attribute.type < Attributor::Flatpack::Config
          top = fetch(key) do
            {}
          end
          attribute.load(top, context).merge!(subselect(key))
        else
          value = fetch(key) do
            raise "couldn't find #{key.inspect} anywhere"
          end
          attribute.load(value, context)
        end
      end

      # search @raw for key
      def fetch(key)
        return @raw[key] if @raw.key?(key)

        _found_key, found_value = @raw.find do |(k, _v)|
          case k
          when ::Symbol, ::String
            k.to_s.casecmp(key.to_s) == 0
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

        selected = @raw.collect do |(k, v)|
          if (match = prefix_match.match(k))
            [match[1], v]
          end
        end.compact
        ::Hash[selected]
      end

      def [](k)
        get k
      end

      def []=(k, v)
        set k, v
      end

      def merge!(other)
        # Not sure if we need to nuke the memozied set of loaded stuff here
        # or not... but it sounds like a good idea.
        @contents = {}
        @raw.merge!(other)

        self
      end
    end
  end
end
