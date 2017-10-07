# frozen_string_literal: true
require 'axlsx'

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
        max_level = @data.max_level
        max_value_length = @data.max_value_length

        ws.add_row(((1..max_level).map {|l| @data.key_header[l - 1] || nil }).concat(
          HTOTConv::Util.pad_array(@data.value_header, max_value_length)),
        :style => Axlsx::STYLE_THIN_BORDER)

        @data.item.each_with_index do |item, item_index|
          key_cell = Array.new(max_level, nil)
          key_cell[item.level - 1] = item.key
          value_cell = HTOTConv::Util.pad_array(item.value, max_value_length)

          ws.add_row(key_cell.concat(value_cell),
                     :style => Axlsx::STYLE_THIN_BORDER)

          (1..max_level).each do |level|
            edges = []
            edges << :left if (level <= item.level)
            edges << :right if ((level < item.level) || (level == max_level))
            edges << :top if ((level >= item.level) || (item_index == 0))
            edges << :bottom if ((level > item.level) || (item_index == @data.item.length - 1))
            ws.rows.last.cells[level - 1].style = ws.styles.add_style(
              :border => { :style => :thin, :color => "00", :edges => edges })
          end
        end

        if @option[:outline_rows]
          outline_begin = Array.new(max_level, nil)
          dummy_end_item = HTOTConv::Outline::Item.new(nil, 1, nil)
          @data.item.concat([dummy_end_item]).each_with_index do |item, item_index|
            (item.level..max_level).each do |level|
              if outline_begin[level - 1]
                if outline_begin[level - 1] < item_index - 1
                  ws.outline_level_rows((outline_begin[level - 1] + 1) + 1, (item_index - 1) + 1, level, false)
                end
                outline_begin[level - 1] = nil
              end
            end
            outline_begin[item.level - 1] = item_index
          end

          # PR randym/axlsx#440 has been added to master branch
          # https://github.com/randym/axlsx/commit/c80c8b9d9be5542471d66afcc2ce4ddd80cac1f7
          # but latest release on rubygems does not contain this.
          # So apply monkey patch to ws.sheet_pr.
          if defined? ws.sheet_pr.outline_pr
            ws.sheet_pr.outline_pr.summary_below = false
          else
            class << ws.sheet_pr # monkey patch
              def to_xml_string(str="".dup)
                tmp_str = "".dup
                super(tmp_str)
                str << tmp_str.sub('<pageSetUpPr', '<outlinePr summaryBelow="0" /><pageSetUpPr')
              end
            end
          end
        end

        case @option[:integrate_cells]
        when :colspan
          @data.item.each_with_index do |item, item_index|
            if item.level < max_level
              ws.merge_cells(ws.rows[item_index + 1].cells[((item.level - 1)..(max_level - 1))])
            end
          end
        when :rowspan
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
