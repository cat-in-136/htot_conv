require 'htot_conv/parser/base'

module HTOTConv
  module Parser
    class SimpleText < Base
      def self.option_help
        {
          :indent => {
            :default => "\t",
            :pat => String,
            :desc => "indent character (default: TAB)",
          },
          :delimiter => {
            :default => nil,
            :pat => String,
            :desc => "separator character of additional data"
          },
        }
      end

      def parse(input)
        indent_regexp = Regexp.new("^(?<indents>(#{Regexp.escape(option[:indent])})*)")
        delimiter_regexp = (option[:delimiter].kind_of?(String))? Regexp.new(Regexp.escape(option[:delimiter])) : option[:delimiter]
        outline = HTOTConv::Outline.new
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
