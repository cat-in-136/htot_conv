# frozen_string_literal: true

require 'htot_conv/generator/base'

module HTOTConv
  module Generator
    class XlsxType4 < XlsxBase
      def self.option_help
        super.merge({
          :integrate_cells => {
            :default => nil,
            :pat => [:colspan, :rowspan, :both],
            :desc => "integrate key cells (specify 'colspan', 'rowspan' or 'both')",
          },
        })
      end

      def output_to_worksheet(ws)
        max_level = @data.max_level
        max_value_length = @data.max_value_length
        row_index = 0

        ((1..max_level).map {|l| @data.key_header[l - 1] || nil }).concat(
          HTOTConv::Util.pad_array(@data.value_header, max_value_length)
        ).each_with_index do |v, col_index|
          ws.add_cell(row_index, col_index, v)
          [:top, :bottom, :left, :right].each do |edge|
            ws[row_index][col_index].change_border(edge, "thin")
          end
        end
        row_index = row_index.succ

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

            key_cell.concat(value_cell).each_with_index do |v, col_index|
              ws.add_cell(row_index, col_index, v)
              [:top, :bottom, :left, :right].each do |edge|
                ws[row_index][col_index].change_border(edge, "thin")
              end
            end

            node.ancestors.each_with_object([node]) do |c_node, descendants|
              if (c_node.item && c_node.item.level)
                edges = []
                edges << :top if (descendants.any? { |v| v.prev })
                edges << :bottom if (descendants.any? { |v| v.next })
                edges.each do |edge|
                  ws[row_index][c_node.item.level - 1].change_border(edge, nil)
                end
              end
              descendants.unshift(c_node)
            end
            (item.level..max_level).each do |level|
              edges = []
              edges << :left unless (level == item.level)
              edges << :right unless (level == max_level)
              edges.each do |edge|
                ws[row_index][level - 1].change_border(edge, nil)
              end
            end

            if [:colspan, :both].include?(@option[:integrate_cells])
              if item.level < max_level
                ws.merge_cells(row_index, item.level - 1, row_index, max_level - 1)
              end
            end

            node.ancestors.each_with_object([node]) do |c_node, descendants|
              rowspan_cells[c_node.item.level - 1] << [row_index, c_node.item.level - 1]
              unless (descendants.any? { |v| v.next })
                if [:rowspan, :both].include?(@option[:integrate_cells])
                  if rowspan_cells[c_node.item.level - 1].length > 1
                    ws.merge_cells(
                      rowspan_cells[c_node.item.level - 1].map(&:first).min,
                      rowspan_cells[c_node.item.level - 1].map(&:last).min,
                      rowspan_cells[c_node.item.level - 1].map(&:first).max,
                      rowspan_cells[c_node.item.level - 1].map(&:last).max,
                    )
                  end
                end
                rowspan_cells[c_node.item.level - 1].clear
              end
              descendants.unshift(c_node)
            end

            (max_level..(max_level + max_value_length - 1)).each do |col_index|
              [:top, :bottom, :left, :right].each do |edge|
                ws[row_index][col_index].change_border(edge, "thin")
              end
            end

            row_index = row_index.succ
          end
        end
      end
    end
  end
end
