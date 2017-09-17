require 'axlsx'

require 'outline2xlsx/generator/base'

module Outline2xlsx
  module Generator
    class XlsxType0 < XlsxBase
      def initialize(data)
        super(data)
        raise ArgumentError, "data is invalid" unless data.valid?
      end

      def output_to_worksheet(ws)
        ws.add_row([@data.key_header[0], 'Level'].concat(@data.value_header),
                   :style => Axlsx::STYLE_THIN_BORDER)

        @data.item.each do |item|
          ws.add_row([item.key, item.level.to_i].concat(item.value),
                     :style => Axlsx::STYLE_THIN_BORDER)
        end
      end
    end
  end
end
