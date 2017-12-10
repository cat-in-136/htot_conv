# frozen_string_literal: true
require 'htot_conv/generator/xlsx_type0.rb'
#require 'htot_conv/generator/xlsx_type1.rb'
require 'htot_conv/generator/xlsx_type2.rb'
#require 'htot_conv/generator/xlsx_type3.rb'
require 'htot_conv/generator/xlsx_type4.rb'
#require 'htot_conv/generator/xlsx_type5.rb'

require 'rinne'

module HTOTConv
  module Generator
    def create(type, *args)
      klass = HTOTConv::Generator.const_get(Rinne.camelize(type.to_s))
      klass.new(*args)
    end
    module_function :create

    def types
      HTOTConv::Generator.constants.reject { |klass|
        klass =~ /Base$/
      }.select { |klass|
        HTOTConv::Generator.const_get(klass).kind_of?(Class)
      }.map { |klass|
        Rinne.to_snake(klass.to_s).to_sym
      }
    end
    module_function :types
  end
end
