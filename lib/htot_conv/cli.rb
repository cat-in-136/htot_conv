# frozen_string_literal: true
require 'optparse'

require 'rinne'

module HTOTConv
  module CLI
    class ScriptOptions
      def initialize
        @options = {
          :from_type => :simple_text,
          :to_type => :xlsx_type2,
        }
        @from_options = {}
        @to_options = {}
      end
      attr_accessor :options, :from_options, :to_options

      def define_options(opts)
        opts.banner       = %q{Hierarchical-Tree Outline Text Converter}
        opts.define_head    %q{Usage: htot_conv [options] [input] [output]}
        opts.separator      %q{}
        opts.separator      %q{Options:}

        from_types = HTOTConv::Parser.types.map { |v| [v, v.to_s.tr("_", "-")] }.flatten
        to_types = HTOTConv::Generator.types.map { |v| [v, v.to_s.tr("_", "-")] }.flatten

        opts.on("-f", "--from-type=TYPE", from_types, "type of input (default: #{options[:from_type]})") do |v|
          options[:from_type] = v.to_s.tr("-", "_")
        end
        opts.on("-t", "--to-type=TYPE", to_types, "type of output (default: #{options[:to_type]})") do |v|
          options[:to_type] = v.to_s.tr("-", "_")
        end
        opts.on("-l", "--list-type", "list input/output type") do
          $stdout << "type of input:\n"
          $stdout << HTOTConv::Parser.types.join(" ") << "\n"
          $stdout << "\n"
          $stdout << "type of output:\n"
          $stdout << HTOTConv::Generator.types.join(" ") << "\n"
          $stdout << "\n"
          exit
        end

        opts.separator ""
        opts.on("-h", "-?", "--help", "Show this message") do
          puts opts
          exit
        end
        opts.on("--version", "Show version") do
          $stdout << "htot_conv #{HTOTConv::VERSION}\n"
          exit
        end

        opts.separator ""
        opts.separator "I/O Options:"
        define_sub_options(opts, HTOTConv::Parser, "from") do |key, v|
          @from_options[key] = v
        end
        define_sub_options(opts, HTOTConv::Generator, "to") do |key, v|
          @to_options[key] = v
        end
      end

      private
      def define_sub_options(opts, klass, prefix) # :yields: key, v
        klass.types.each do |type|
          type_klass = klass.const_get(Rinne.camelize(type.to_s))
          type_klass.option_help.each do |key,v|
            long_option = "--#{prefix}-#{key.to_s.tr('_','-')}=VAL"
            cmd_switch = opts.top.list.find { |v| v.kind_of?(OptionParser::Switch) && v.long.include?(long_option) }
            if cmd_switch
              cmd_switch.desc << "For #{type}, #{v[:desc]}"
            else
              opts.on(long_option, v[:pat], "For #{type}, #{v[:desc]}") do |v|
                yield key, v
              end
            end
          end
        end
      end
    end

    def optparse(args)
      script_opts = ScriptOptions.new
      OptionParser.new do |opts|
        script_opts.define_options(opts)

        begin
          opts.parse!(args)
        rescue OptionParser::ParseError => ex
          $stderr << ex.message << "\n"
          exit 1
        end
      end
      script_opts
    end
    module_function :optparse

    def main(args=ARGV)
      script_opts = HTOTConv::CLI.optparse(args)
      options = script_opts.options
      from_options = script_opts.from_options
      to_options = script_opts.to_options
      
      inio  = ((args.length > 0) && (args[0] != "-"))? File.open(args[0], "rb") : $stdin
      outio = ((args.length > 1) && (args[1] != "-"))? File.open(args[1], "wb") : $stdout
      
      HTOTConv.convert(inio, options[:from_type], outio, options[:to_type], from_options, to_options)
    end
    module_function :main
  end
end