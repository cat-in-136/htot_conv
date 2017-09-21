require 'htot_conv/generator/xlsx_type0.rb'
require 'htot_conv/generator/xlsx_type1.rb'
require 'htot_conv/generator/xlsx_type2.rb'
require 'htot_conv/generator/xlsx_type4.rb'
require 'htot_conv/generator/xlsx_type5.rb'

require 'rinne'

module HTOTConv
  module Generator
    def create(type, *args)
      klass = HTOTConv::Generator.const_get(Rinne.camelize(type.to_s))
      klass.new(*args)
    end
    module_function :create
  end
end
