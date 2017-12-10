# frozen_string_literal: true

require 'htot_conv/generator/base'

module HTOTConv
  module Generator
    class XlsxType3 < XlsxBase
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
        row_index = 0

        [
          @data.key_header[0],
          *(HTOTConv::Util.pad_array([@data.value_header[0]], max_level)),
          *(HTOTConv::Util.pad_array(
            (@data.value_header.length <= 1)? [] : @data.value_header.last(@data.value_header.length - 1),
            [max_value_length - 1, 0].max)),
        ].each_with_index do |v, col_index|
          ws.add_cell(row_index, col_index, v)
          [:top, :bottom, :left, :right].each do |edge|
            ws[row_index][col_index].change_border(edge, "thin")
          end
        end
        1.upto(max_level) do |col_index|
          edges = []
          edges << :left unless (col_index <= 1)
          edges << :right unless (col_index >= max_level)
          edges.each do |edge|
            ws[row_index][col_index].change_border(edge, nil)
          end
        end
        row_index = row_index.succ

        @data.item.each_with_index do |item, item_index|
          key_value_cell = Array.new(max_level + 1, nil)
          key_value_cell[item.level - 1] = item.key
          key_value_cell[item.level    ] = item.value[0]
          rest_value_cell = HTOTConv::Util.pad_array(
            (item.value.length <= 1)? [] : item.value.last(item.value.length - 1),
            [max_value_length - 1, 0].max)

          key_value_cell.concat(rest_value_cell).each_with_index do |v, col_index|
            ws.add_cell(row_index, col_index, v)
            [:top, :bottom, :left, :right].each do |edge|
              ws[row_index][col_index].change_border(edge, "thin")
            end
          end
          0.upto(max_level) do |col_index|
            edges = []
            edges << :left unless (col_index <= item.level)
            edges << :right unless ((col_index < item.level) || (col_index >= max_level))
            edges << :top unless ((col_index > (item.level - 2)) || (item_index == 0))
            edges << :bottom unless ((col_index > (item.level - 1)) || (item_index == @data.item.length - 1))
            edges.each do |edge|
              ws[row_index][col_index].change_border(edge, nil)
            end
          end
          row_index = row_index.succ
        end

        if [:colspan, :both].include?(@option[:integrate_cells])
          if max_level > 1
            ws.merge_cells(0, 1, 0, max_level)
          end
          @data.item.each_with_index do |item, item_index|
            if item.level < max_level
              ws.merge_cells(item_index + 1, item.level, item_index + 1, max_level)
            end
          end
        end
        if [:rowspan, :both].include?(@option[:integrate_cells])
          @data.item.each_with_index do |item, item_index|
            min_row_index = item_index + 1
            max_row_index = min_row_index
            ((item_index + 1)..(@data.item.length - 1)).each do |i|
              break if @data.item[i].level <= item.level
              max_row_index = i + 1
            end

            unless min_row_index == max_row_index
              ws.merge_cells(min_row_index, item.level - 1, max_row_index, item.level - 1)
            end
          end
        end
      end
    end
  end
end
