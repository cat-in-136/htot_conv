
require 'axlsx'

require 'outline2xlsx/generator/base'

module Outline2xlsx
  module Generator
    class XlsxType1 < XlsxBase
      def initialize(data)
        super(data)
        raise ArgumentError, "data is invalid" unless data.valid?
      end

      def output_to_worksheet(ws)
        max_item_length = [
          @data.value_header.length,
          @data.item.map { |v| v.value.length }.max,
        ].max

        ws.add_row([@data.key_header[0]].concat(
          @data.value_header.concat([nil] * (max_item_length - @data.value_header.length))),
        :style => Axlsx::STYLE_THIN_BORDER)

        @data.item.each do |item|
          ws.add_row([item.key].concat(
            item.value.concat([nil] * (max_item_length - item.value.length))),
          :style => Axlsx::STYLE_THIN_BORDER)
        end
      end
    end
  end
end

