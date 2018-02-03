# frozen_string_literal: true

require 'rubyXL'

module HTOTConv
  module Generator
    class Base
      def initialize(data, option={})
        data.validate
        @data = data
        @option = self.class.option_help.inject({}) { |h, pair| h[pair[0]] = pair[1][:default]; h}.merge(option)
      end
      def self.option_help
        {}
      end

      def output(outputfile)
        raise NotImplementedError.new("#{self.class.name}.#{__method__} is an abstract method.")
      end
    end

    class XlsxBase < Base
      def self.option_help
        super.merge({
          :shironuri => {
            :default => false,
            :pat => FalseClass,
            :desc => "Fill all the cells with white color (default: no)",
          },
        })
      end

      def output_to_worksheet(ws)
        raise NotImplementedError.new("#{self.class.name}.#{__method__} is an abstract method.")
      end

      def output(outputfile)
        wb = RubyXL::Workbook.new
        shironuri(wb, wb[0]) if @option[:shironuri]
        output_to_worksheet(wb[0])
        wb.write(outputfile)
      end

      private
      def shironuri(wb, ws)
        style_index = wb.modify_fill(nil, "ffffff")
        ws.cols << RubyXL::ColumnRange.new(:min => 1, :max => 0x4000, :style_index => style_index)
      end
    end
  end
end
