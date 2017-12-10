# frozen_string_literal: true

require 'htot_conv/generator/base'

module HTOTConv
  module Generator
    class XlsxType2 < XlsxBase
      def self.option_help
        {
          :integrate_cells => {
            :default => nil,
            :pat => [:colspan, :rowspan],
            :desc => "integrate key cells (specify 'colspan' or 'rowspan')",
          },
          :outline_rows => {
            :default => false,
            :pat => FalseClass,
            :desc => "group rows (default: no)",
          },
        }
      end

      def output_to_worksheet(ws)
        row_index = 0
        max_level = @data.max_level
        max_value_length = @data.max_value_length

        (((1..max_level).map {|l| @data.key_header[l - 1] || nil }).concat(
          HTOTConv::Util.pad_array(@data.value_header, max_value_length))
        ).each_with_index do |v, col_index|
          ws.add_cell(row_index, col_index, v)
          [:top, :bottom, :left, :right].each do |edge|
            ws[row_index][col_index].change_border(edge, "thin")
          end
        end
        row_index = row_index.succ

        @data.item.each_with_index do |item, item_index|
          key_cell = Array.new(max_level, nil)
          key_cell[item.level - 1] = item.key
          value_cell = HTOTConv::Util.pad_array(item.value, max_value_length)

          key_cell.concat(value_cell).each_with_index do |v, col_index|
            ws.add_cell(row_index, col_index, v)
            if col_index >= max_level
              [:top, :bottom, :left, :right].each do |edge|
                ws[row_index][col_index].change_border(edge, "thin")
              end
            end
          end

          (1..max_level).each do |level|
            edges = []
            edges << :left if (level <= item.level)
            edges << :right if ((level < item.level) || (level == max_level))
            edges << :top if ((level >= item.level) || (item_index == 0))
            edges << :bottom if ((level > item.level) || (item_index == @data.item.length - 1))
            edges.each do |edge|
              ws[row_index][level - 1].change_border(edge, "thin")
            end
          end

          row_index = row_index.succ
        end

        if @option[:outline_rows]
          @data.item.each_with_index do |item, item_index|
            ws[item_index + 1].outline_level = (item.level > 1)? (item.level - 1) : nil
          end

          ws.sheet_pr ||= RubyXL::WorksheetProperties.new
          ws.sheet_pr.outline_pr ||= RubyXL::OutlineProperties.new
          ws.sheet_pr.outline_pr.summary_below = false
        end

        case @option[:integrate_cells]
        when :colspan
          @data.item.each_with_index do |item, item_index|
            if item.level < max_level
              ws.merge_cells(item_index + 1, item.level - 1, item_index + 1, max_level - 1)
            end
          end
        when :rowspan
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
