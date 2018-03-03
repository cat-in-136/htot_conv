# frozen_string_literal: true
require 'htot_conv/parser/base'

module HTOTConv
  module Parser
    class Mspdi < Base
      def self.option_help
        {
          :key_header => {
            :default => [],
            :pat => Array,
            :desc => "key header",
          },
          :value_header => {
            :default => [],
            :pat => Array,
            :desc => "value header",
          },
        }
      end

      def parse(input)
        outline = HTOTConv::Outline.new
        outline.key_header = @option[:key_header]
        outline.value_header = @option[:value_header]

        parser = Nokogiri::XML::SAX::Parser.new(ListDoc.new(outline))
        parser.parse(input)

        outline
      end

      class ListDoc < Nokogiri::XML::SAX::Document
        def initialize(outline)
          @outline = outline
          @breadcrumb = []
        end

        def start_element(name, attrs=[])
          @breadcrumb << name
          @values = {} if name == 'Task'
        end

        def end_element(name)
          @breadcrumb.pop
          generate_outline_item if name == 'Task'
        end

        def characters(string)
          if @breadcrumb.include?('Task')
            type = @breadcrumb.last
            @values[type] = ''.dup unless @values.include?(type)
            @values[type] << string
          end
        end

        alias :cdata_block :characters

        private
        def generate_outline_item
          text = ""
          level = 1
          values = []
          @values.each do |pair|
            attr_name, attr_val = pair
            if attr_name == "Name"
              text = attr_val
            elsif attr_name == "OutlineLevel"
              level = attr_val.to_i
            else
              if @outline.value_header.include?(attr_name)
                values[@outline.value_header.index(attr_name)] = attr_val
              end
            end
          end

          @outline.add_item(text, level, values)
        end
      end

    end
  end
end
