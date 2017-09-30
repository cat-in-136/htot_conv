# frozen_string_literal: true
module HTOTConv
  module Parser
    class Base
      def initialize(option={})
        @option = self.class.option_help.inject({}) { |h, pair| h[pair[0]] = pair[1][:default]; h}.merge(option)
      end
      attr_accessor :option

      def self.option_help
        {}
      end
    end
  end
end
