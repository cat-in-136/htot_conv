# frozen_string_literal: true

require 'htot_conv/generator/base'

module HTOTConv
  module Generator
    class XlsxType1 < XlsxBase
      def self.option_help
        {
          :outline_rows => {
            :default => false,
            :pat => FalseClass,
            :desc => "group rows (default: no)",
          },
        }
      end

      def output_to_worksheet(ws)
        row_index = 0
        max_value_length = @data.max_value_length

        [@data.key_header[0]].concat(
          HTOTConv::Util.pad_array(@data.value_header, max_value_length)
        ).each_with_index do |v, col_index|
          ws.add_cell(row_index, col_index, v)
          [:top, :bottom, :left, :right].each do |edge|
            ws[row_index][col_index].change_border(edge, "thin")
          end
        end
        row_index = row_index.succ

        @data.item.each do |item|
          ([item.key].concat(
            HTOTConv::Util.pad_array(item.value, max_value_length))
          ).each_with_index do |v, col_index|
            ws.add_cell(row_index, col_index, v)
            [:top, :bottom, :left, :right].each do |edge|
              ws[row_index][col_index].change_border(edge, "thin")
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
      end
    end
  end
end

