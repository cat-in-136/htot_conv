require 'axlsx'

require 'outline2xlsx/generator/base'

module Outline2xlsx
  module Generator
    class XlsxType5 < XlsxBase
      def initialize(data)
        super(data)
        raise ArgumentError, "data is invalid" unless data.valid?
      end

      def output_to_worksheet(ws)
        max_level = @data.max_level
        max_value_length = @data.max_value_length

        ws.add_row(((1..max_level).map {|l| @data.key_header[l - 1] || nil }).concat(
          Outline2xlsx::Util.pad_array(@data.value_header, max_value_length)),
        :style => Axlsx::STYLE_THIN_BORDER)

        @data.to_tree.descendants.each do |node|
          if node.leaf?
            item = node.item

            key_cell = Array.new(max_level, nil)
            parent_node = node
            while ((parent_node.item) && !(parent_node.root?))
              key_cell[parent_node.item.level - 1] = parent_node.item.key
              parent_node = parent_node.parent
            end

            value_cell = Outline2xlsx::Util.pad_array(item.value, max_value_length)

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
      end
    end
  end
end
