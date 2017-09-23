require 'htot_conv/parser/base'

module HTOTConv
  module Parser
    class HtmlList < Base
      def initialize(option={})
        @option = {}.merge(option)
      end

      def parse(input)
        outline = HTOTConv::Outline.new
        outline.key_header = []
        outline.value_header = []

        parser = Nokogiri::HTML::SAX::Parser.new(ListDoc.new(outline))
        parser.parse(input)

        outline
      end

      class ListDoc < Nokogiri::XML::SAX::Document
        def initialize(outline)
          @outline = outline
          @breadcrumb = []
          @li_text = nil
        end

        def start_element(name, attrs=[])
          if ((name == "ul") || (name == "ol"))
            generate_outline_item unless @li_text.nil?
            @breadcrumb << name
          elsif name == "li"
            @li_text = "".dup if @breadcrumb.length > 0
          end
        end

        def end_element(name)
          if ((name == "ul") || (name == "ol"))
            generate_outline_item unless @li_text.nil?
            @breadcrumb.pop
          elsif name == "li"
            generate_outline_item unless @li_text.nil?
          end
        end

        def characters(string)
          @li_text << string unless @li_text.nil?
        end

        def cdata_block(string)
          @li_text << string unless @li_text.nil?
        end

        private
        def generate_outline_item
          level = @breadcrumb.length
          @outline.add_item(@li_text.strip, level, [])
          @li_text = nil
        end
      end

    end
  end
end
