# frozen_string_literal: true
require 'axlsx'

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

        ws.add_row([
          @data.key_header[0],
          *(HTOTConv::Util.pad_array([@data.value_header[0]], max_level)),
          *((@data.value_header.length <= 1)? [] : @data.value_header.last(@data.value_header.length - 1)),
        ], :style => Axlsx::STYLE_THIN_BORDER)
        1.upto(max_level) do |col_idx|
          edges = [:top, :bottom]
          edges << :left if (col_idx <= 1)
          edges << :right if (col_idx >= max_level)
          ws.rows.last.cells[col_idx].style = ws.styles.add_style(
            :border => { :style => :thin, :color => "00", :edges => edges })
        end

        @data.item.each_with_index do |item, item_index|
          key_value_cell = Array.new(max_level + 1, nil)
          key_value_cell[item.level - 1] = item.key
          key_value_cell[item.level    ] = item.value[0]
          rest_value_cell = (item.value.length <= 1)? [] :
            HTOTConv::Util.pad_array(item.value.last(item.value.length - 1), max_value_length - 1)

          ws.add_row(key_value_cell.concat(rest_value_cell),
                     :style => Axlsx::STYLE_THIN_BORDER)

          0.upto(max_level) do |col_idx|
            edges = []

            edges << :left if (col_idx <= item.level)
            edges << :right if ((col_idx < item.level) || (col_idx >= max_level))
            edges << :top if ((col_idx > (item.level - 2)) || (item_index == 0))
            edges << :bottom if ((col_idx > (item.level - 1)) || (item_index == @data.item.length - 1))
            ws.rows.last.cells[col_idx].style = ws.styles.add_style(
              :border => { :style => :thin, :color => "00", :edges => edges })
          end
        end

        if [:colspan, :both].include?(@option[:integrate_cells])
          if max_level > 1
            ws.merge_cells(ws.rows[0].cells[1..(max_level)])
          end
          @data.item.each_with_index do |item, item_index|
            if item.level < max_level
              ws.merge_cells(ws.rows[item_index + 1].cells[(item.level..max_level)])
            end
          end
        end
        if [:rowspan, :both].include?(@option[:integrate_cells])
          @data.item.each_with_index do |item, item_index|
            cells = [ws.rows[item_index + 1].cells[item.level - 1]]
            ((item_index + 1)..(@data.item.length - 1)).each do |i|
              break if @data.item[i].level <= item.level
              cells << ws.rows[i + 1].cells[item.level - 1]
            end

            ws.merge_cells(cells) if cells.length > 1
          end
        end
      end
    end
  end
end
