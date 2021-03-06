# frozen_string_literal: true
require 'htot_conv/parser/base.rb'
require 'htot_conv/parser/simple_text.rb'
require 'htot_conv/parser/dir_tree.rb'
require 'htot_conv/parser/html_list.rb'
require 'htot_conv/parser/mspdi.rb'
require 'htot_conv/parser/opml.rb'

module HTOTConv
  module Parser
    def create(type, *args)
      klass = HTOTConv::Parser.const_get(Rinne.camelize(type.to_s))
      klass.new(*args)
    end
    module_function :create

    def types
      HTOTConv::Parser.constants.reject { |klass|
        klass =~ /Base$/
      }.select { |klass|
        HTOTConv::Parser.const_get(klass).kind_of?(Class)
      }.map { |klass|
        Rinne.to_snake(klass.to_s).to_sym
      }
    end
    module_function :types
  end
end
