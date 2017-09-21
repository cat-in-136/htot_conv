require 'htot_conv/parser/simple_text.rb'

module HTOTConv
  module Parser
    def create(type, *args)
      klass = HTOTConv::Parser.const_get(Rinne.camelize(type.to_s))
      klass.new(*args)
    end
    module_function :create
  end
end
