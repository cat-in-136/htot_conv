require 'axlsx'

require 'outline2xlsx/generator/base'

module Outline2xlsx
  module Generator
    class XlsxType2 < XlsxBase
      def initialize(data)
        super(data)
        raise ArgumentError, "data is invalid" unless data.valid?
      end

      def output_to_worksheet(ws)
        max_level = [
          @data.key_header.length,
          @data.item.map { |v| v.level.to_i }.max
        ].max

        ws.add_row(((0..(max_level - 1)).map { |i| @data.key_header[i] || nil }).concat(@data.value_header),
                   :style => Axlsx::STYLE_THIN_BORDER)

        @data.item.each_with_index do |item, item_index|
          key_area = Array.new(max_level, nil)
          key_area[item.level - 1] = item.key

          ws.add_row(key_area.concat(item.value),
                     :style => Axlsx::STYLE_THIN_BORDER)

          (1..max_level).each do |level|
            edges = []
            edges << :left if (level <= item.level)
            edges << :right if ((level < item.level) || (level == max_level))
            edges << :top if ((level >= item.level) || (item_index == 0))
            edges << :bottom if ((level > item.level) || (item_index == @data.item.length - 1))
            ws.rows.last.cells[level - 1].style = ws.styles.add_style(
              :border => { :style => :thin, :color => "00", :edges => edges })
          end
        end
      end
    end
  end
end
