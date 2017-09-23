require 'htot_conv/version'

require 'htot_conv/util'
require 'htot_conv/outline'
require 'htot_conv/generator'
require 'htot_conv/parser'

module HTOTConv

  def convert(input, input_type, output, output_type, input_option={}, output_option={})
    parser = HTOTConv::Parser.create(input_type, input_option)
    outline = parser.parse(input)
    generator = HTOTConv::Generator.create(output_type, outline, output_option)
    generator.output(output)
  end
  module_function :convert

end
