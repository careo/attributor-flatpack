# Sometimes a multline string when read in by ruby has escaped newlines, sometimes not.
# This type will remove any escaping of newline from a string.

module Attributor
  module Flatpack
    class MultilineString < Attributor::String

      def self.load(value, context = Attributor::DEFAULT_ROOT_CONTEXT, **options)
        value.gsub('\\n', "\n")
      rescue StandardError
        super
      end

      def self.example(_context = nil, options: {})
        "-----BEGIN EC PRIVATE KEY-----\\nMIHcAgEBBEI\\n3abcdefghijklmnop==\\n-----END EC PRIVATE KEY-----"
      end

    end
  end
end