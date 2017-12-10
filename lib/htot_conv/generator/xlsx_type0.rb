# frozen_string_literal: true

require 'htot_conv/generator/base'

module HTOTConv
  module Generator
    class XlsxType0 < XlsxBase
      def output_to_worksheet(ws)
        row_index = 0
        max_value_length = @data.max_value_length

        [@data.key_header[0], 'Outline Level'].concat(
          HTOTConv::Util.pad_array(@data.value_header, max_value_length)
        ).each_with_index do |v, col_index|
          ws.add_cell(row_index, col_index, v)
          [:top, :bottom, :left, :right].each do |edge|
            ws[row_index][col_index].change_border(edge, "thin")
          end
        end
        row_index = row_index.succ

        @data.item.each do |item|
          [item.key, item.level.to_i].concat(
            HTOTConv::Util.pad_array(item.value, max_value_length)
          ).each_with_index do |v, col_index|
            ws.add_cell(row_index, col_index, v)
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
