require 'axlsx'

require 'htot_conv/generator/base'

module HTOTConv
  module Generator
    class XlsxType2 < XlsxBase
      def output_to_worksheet(ws)
        max_level = @data.max_level
        max_value_length = @data.max_value_length

        ws.add_row(((1..max_level).map {|l| @data.key_header[l - 1] || nil }).concat(
          HTOTConv::Util.pad_array(@data.value_header, max_value_length)),
        :style => Axlsx::STYLE_THIN_BORDER)

        @data.item.each_with_index do |item, item_index|
          key_cell = Array.new(max_level, nil)
          key_cell[item.level - 1] = item.key
          value_cell = HTOTConv::Util.pad_array(item.value, max_value_length)

          ws.add_row(key_cell.concat(value_cell),
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