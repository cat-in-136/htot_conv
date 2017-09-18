require 'axlsx'

require 'outline2xlsx/generator/base'

module Outline2xlsx
  module Generator
    class XlsxType0 < XlsxBase
      def output_to_worksheet(ws)
        max_value_length = @data.max_value_length

        ws.add_row([@data.key_header[0], 'Level'].concat(
          Outline2xlsx::Util.pad_array(@data.value_header, max_value_length)),
        :style => Axlsx::STYLE_THIN_BORDER)

        @data.item.each do |item|
          ws.add_row([item.key, item.level.to_i].concat(
            Outline2xlsx::Util.pad_array(item.value, max_value_length)),
          :style => Axlsx::STYLE_THIN_BORDER)
        end
      end
    end
  end
end
