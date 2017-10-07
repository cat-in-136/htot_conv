# frozen_string_literal: true

require 'axlsx'

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
        max_value_length = @data.max_value_length

        ws.add_row([@data.key_header[0]].concat(
          HTOTConv::Util.pad_array(@data.value_header, max_value_length)),
        :style => Axlsx::STYLE_THIN_BORDER)

        @data.item.each do |item|
          ws.add_row([item.key].concat(
            HTOTConv::Util.pad_array(item.value, max_value_length)),
          :style => Axlsx::STYLE_THIN_BORDER)
        end

        if @option[:outline_rows]
          max_level = @data.max_level
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
      end
    end
  end
end

