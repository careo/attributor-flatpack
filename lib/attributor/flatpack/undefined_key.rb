module Attributor
  module Flatpack
    class UndefinedKey < Attributor::LoadError
      def initialize(key, context)
        ctx = Attributor.humanize_context(context)
        super "Undefined key received: #{key.inspect} for #{ctx}"
      end
    end
  end
end
