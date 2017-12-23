# frozen_string_literal: true

require 'htot_conv/generator/base'

module HTOTConv
  module Generator
    class XlsxType5 < XlsxBase
      def self.option_help
        {
          :integrate_cells => {
            :default => nil,
            :pat => [:colspan],
            :desc => "integrate key cells (specify 'colspan')",
          },
        }
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

        @data.to_tree.descendants.each do |node|
          if node.leaf?
            item = node.item

            key_cell = Array.new(max_level, nil)
            key_cell[node.item.level - 1] = item.key
            node.ancestors.each do |ancestor|
              key_cell[ancestor.item.level - 1] = ancestor.item.key if ancestor.item
            end

            value_cell = HTOTConv::Util.pad_array(item.value, max_value_length)

            key_cell.concat(value_cell).each_with_index do |v, col_index|
              ws.add_cell(row_index, col_index, v)
              [:top, :bottom, :left, :right].each do |edge|
                ws[row_index][col_index].change_border(edge, "thin")
              end
            end

            (item.level..max_level).each do |level|
              edges = []
              edges << :left unless (level == item.level)
              edges << :right unless (level == max_level)
              edges.each do |edge|
                ws[row_index][level - 1].change_border(edge, nil)
              end
            end

            if [:colspan].include?(@option[:integrate_cells])
              if item.level < max_level
                ws.merge_cells(row_index, item.level - 1, row_index, max_level - 1)
              end
            end
            row_index = row_index.succ
          end
        end

        ws.auto_filter ||= RubyXL::AutoFilter.new
        ws.auto_filter.ref = RubyXL::Reference.new(0, row_index - 1, 0, max_level + max_value_length -1)
      end
    end
  end
end
