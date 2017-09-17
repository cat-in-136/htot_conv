require 'axlsx'

module Outline2xlsx
  module Generator
    class XlsxType0
      def initialize(data)
        @data = data
      end

      def output_to_worksheet(ws)
        ws.add_row(
          [@data[:key_header][0], 'Level'].concat(@data[:value_header]),
          :style => Axlsx::STYLE_THIN_BORDER
        )

        @data[:item].each do |item|
          ws.add_row(
            [item[:key], item[:level].to_i].concat(item[:value]),
            :style => Axlsx::STYLE_THIN_BORDER,
          )
        end
      end

      def output(outputfile)
         p = Axlsx::Package.new
         p.workbook do |wb|
           wb.add_worksheet do |ws|
             output_to_worksheet(ws)
           end
         end
         p.serialize(outputfile)
      end
    end
  end
end
