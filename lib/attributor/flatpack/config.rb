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

        self.class.keys.each do |k, _v|
          self.define_accessors(k)
        end
      end

      def define_accessors(name)
        define_reader(name)
        define_writer(name)
      end

      def define_reader(name)
        define_singleton_method(name) do
          get(name)
        end

        attribute = self.class.keys[name]
        if attribute.type == Attributor::Boolean
          define_singleton_method(name.to_s + '?') do
            !!get(name)
          end
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
            # raise "couldn't find #{key.inspect} anywhere"
            nil
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

      # shamelessly copied from Attributor::Model's #validate :(
      def validate(context = Attributor::DEFAULT_ROOT_CONTEXT)
        self.validate_attributes(context) +
          self.validate_requirements(context)
      end

      def validate_attributes(context)
        self.class.attributes.each_with_object([]) do |(name, attr), errors|
          sub_context = self.generate_subcontext(context, name)
          value = self.get(name)
          errors.push(*attr.validate(value, sub_context))
        end
      end

      def validate_requirements(context)
        self.class.requirements.each_with_object([]) do |req, errors|
          errors.push(req.validate(@contents, context))
        end
      end

      def pretty_print(context: [])
        self.collect do |k, v|
          sub_context = context + [k]
          case v
          when Attributor::Flatpack::Config
            v.pretty_print(context: context | [k])
          else
            "#{sub_context.join('.')}=#{v.inspect}"
          end
        end.flatten
      end
    end
  end
end
