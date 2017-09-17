module Outline2xlsx
  module Parser
    class SimpleText
      def initialize(option={})
        @option = { :indent => "\t", :delimiter => nil }.merge(option)
      end
      attr_accessor :option

      def parse(input)
        indent_regexp = Regexp.new("^(?<indents>(#{Regexp.escape(option[:indent])})*)")
        delimiter_regexp = (option[:delimiter].kind_of?(Regexp))? option[:delimiter] : Regexp.new(Regexp.escape(option[:delimiter]))
        outline = Outline2xlsx::Outline.new
        outline.key_header = []
        outline.value_header = []

        input.each_line do |line|
          level = 1
          value = []
          if (option[:indent] || '').length > 0
            indents = indent_regexp.match(line)[:indents]
            level = 1 + indents.length / option[:indent].length
            line = line.sub(indent_regexp, "")
          end

          line = line.strip
          if delimiter_regexp
            key = line.split(delimiter_regexp)[0]
            value = line.split(delimiter_regexp)[1..-1] || []
          else
            key = line
          end

          outline.add_item(key, level, value)
        end

        outline
      end
    end
  end
end
