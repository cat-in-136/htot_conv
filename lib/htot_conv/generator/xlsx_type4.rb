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
            key_cell[node.item.level - 1] = item.key
            node.ancestors.each do |ancestor|
              key_cell[ancestor.item.level - 1] = ancestor.item.key if ancestor.item
              break if ancestor.prev
            end

            value_cell = HTOTConv::Util.pad_array(item.value, max_value_length)

            ws.add_row(key_cell.concat(value_cell),
                       :style => Axlsx::STYLE_THIN_BORDER)

            [node].concat(node.ancestors.to_a).each do |ancestor|
              if (ancestor.parent && ancestor.parent.item && ancestor.parent.item.level)
                edges = [:left, :right]
                edges << :top unless ancestor.prev
                edges << :bottom unless ancestor.next
                ws.rows.last.cells[ancestor.parent.item.level - 1].style = ws.styles.add_style(
                  :border => { :style => :thin, :color => "00", :edges => edges })
              end
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

            node.ancestors.inject(node) do |c_node, a_node|
              rowspan_cells[a_node.item.level - 1] << ws.rows.last.cells[a_node.item.level - 1]
              unless c_node.next # if c_node is last?
                if [:rowspan, :both].include?(@option[:integrate_cells])
                  if rowspan_cells[a_node.item.level - 1].length > 1
                    ws.merge_cells(rowspan_cells[a_node.item.level - 1])
                  end
                end
                rowspan_cells[a_node.item.level - 1].clear 
              end
              a_node
            end
          end
        end
      end
    end
  end
end
