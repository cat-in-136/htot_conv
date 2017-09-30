# frozen_string_literal: true
require 'axlsx'

require 'htot_conv/generator/base'

module HTOTConv
  module Generator
    class XlsxType5 < XlsxBase
      def output_to_worksheet(ws)
        max_level = @data.max_level
        max_value_length = @data.max_value_length

        ws.add_row(((1..max_level).map {|l| @data.key_header[l - 1] || nil }).concat(
          HTOTConv::Util.pad_array(@data.value_header, max_value_length)),
        :style => Axlsx::STYLE_THIN_BORDER)

        @data.to_tree.descendants.each do |node|
          if node.leaf?
            item = node.item

            key_cell = Array.new(max_level, nil)
            key_cell[node.item.level - 1] = item.key
            node.ancestors do |ancestor|
              key_cell[ancestor.item.level - 1] = ancestor.item.key if ancestor.item
            end

            value_cell = HTOTConv::Util.pad_array(item.value, max_value_length)

            ws.add_row(key_cell.concat(value_cell),
                       :style => Axlsx::STYLE_THIN_BORDER)

            (item.level..max_level).each do |level|
              edges = [:top, :bottom]
              edges << :left if (level == item.level)
              edges << :right if (level == max_level)
              ws.rows.last.cells[level - 1].style = ws.styles.add_style(
                :border => { :style => :thin, :color => "00", :edges => edges })
            end
          end
        end

        ws.auto_filter = "A1:#{ws.rows.last.cells[max_level + max_value_length - 1].r}"
      end
    end
  end
end
