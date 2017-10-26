# frozen_string_literal: true
require 'axlsx'

require 'htot_conv/generator/base'

module HTOTConv
  module Generator
    class XlsxType4 < XlsxBase
      def self.option_help
        {
          :integrate_cells => {
            :default => nil,
            :pat => [:colspan, :rowspan, :both],
            :desc => "integrate key cells (specify 'colspan', 'rowspan' or 'both')",
          },
        }
      end

      def output_to_worksheet(ws)
        max_level = @data.max_level
        max_value_length = @data.max_value_length

        ws.add_row(((1..max_level).map {|l| @data.key_header[l - 1] || nil }).concat(
          HTOTConv::Util.pad_array(@data.value_header, max_value_length)),
        :style => Axlsx::STYLE_THIN_BORDER)

        rowspan_cells = Array.new(max_level) { [] }
        @data.to_tree.descendants.each do |node|
          if node.leaf?
            item = node.item

            key_cell = Array.new(max_level, nil)
            [node].concat(node.ancestors.to_a).each do |c_node|
              key_cell[c_node.item.level - 1] = c_node.item.key if c_node.item
              break if c_node.prev
            end

            value_cell = HTOTConv::Util.pad_array(item.value, max_value_length)

            ws.add_row(key_cell.concat(value_cell),
                       :style => Axlsx::STYLE_THIN_BORDER)

            node.ancestors.each_with_object([node]) do |c_node, descendants|
              if (c_node.item && c_node.item.level)
                edges = [:left, :right]
                edges << :top unless (descendants.any? { |v| v.prev })
                edges << :bottom unless (descendants.any? { |v| v.next })
                ws.rows.last.cells[c_node.item.level - 1].style = ws.styles.add_style(
                  :border => { :style => :thin, :color => "00", :edges => edges })
              end
              descendants.unshift(c_node)
            end
            (item.level..max_level).each do |level|
              edges = [:top, :bottom]
              edges << :left if (level == item.level)
              edges << :right if (level == max_level)
              ws.rows.last.cells[level - 1].style = ws.styles.add_style(
                :border => { :style => :thin, :color => "00", :edges => edges })
            end

            if [:colspan, :both].include?(@option[:integrate_cells])
              if item.level < max_level
                ws.merge_cells(ws.rows.last.cells[((item.level - 1)..(max_level - 1))])
              end
            end

            node.ancestors.each_with_object([node]) do |c_node, descendants|
              rowspan_cells[c_node.item.level - 1] << ws.rows.last.cells[c_node.item.level - 1]
              unless (descendants.any? { |v| v.next })
                if [:rowspan, :both].include?(@option[:integrate_cells])
                  if rowspan_cells[c_node.item.level - 1].length > 1
                    ws.merge_cells(rowspan_cells[c_node.item.level - 1])
                  end
                end
                rowspan_cells[c_node.item.level - 1].clear
              end
              descendants.unshift(c_node)
            end
          end
        end
      end
    end
  end
end
