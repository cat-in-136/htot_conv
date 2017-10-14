# frozen_string_literal: true
require 'htot_conv/parser/base'

module HTOTConv
  module Parser
    class Opml < Base
      def self.option_help
        {
          :key_header => {
            :default => [],
            :pat => Array,
            :desc => "key header",
          },
        }
      end

      def parse(input)
        outline = HTOTConv::Outline.new
        outline.key_header = @option[:key_header]
        outline.value_header = []

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
          if (name == "outline")
            @breadcrumb << name
            generate_outline_item(attrs)
          end
        end

        def end_element(name)
          @breadcrumb.pop if (name == "outline")
        end

        private
        def generate_outline_item(attrs)
          text = ""
          level = @breadcrumb.length
          values = []
          attrs.each do |pair|
            attr_name, attr_val = pair
            if attr_name == "text"
              text = attr_val
            else
              unless @outline.value_header.include?(attr_name)
                @outline.value_header << attr_name 
                values[@outline.value_header.length - 1] = attr_val
              else
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
