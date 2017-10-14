# frozen_string_literal: true
require 'htot_conv/parser/base'

module HTOTConv
  module Parser
    class DirTree < Base
      def self.option_help
        {
          :key_header => {
            :default => [],
            :pat => Array,
            :desc => "key header",
          },
          :glob_pattern => {
            :default => "**/*",
            :pat => String,
            :desc => "globbing pattern (default: \"**/*\")",
          },
          :dir_indicator => {
            :default => "",
            :pat => String,
            :desc => "append directory indicator",
          },
        }
      end

      def parse(input=Dir.pwd)
        outline = HTOTConv::Outline.new
        outline.key_header = @option[:key_header]
        outline.value_header = []

        outline_item = Set.new
        Dir.chdir(input) do
          Dir.glob(@option[:glob_pattern]).each do |f|
            f.split(File::SEPARATOR).inject(nil) do |parent_path, v|
              file_path = (parent_path)? File.join(parent_path, v) : v
              outline_item << file_path
              file_path
            end
          end

          outline_item.sort.each do |file_path|
            key = File.basename(file_path)
            key << "#{option[:dir_indicator]}" if FileTest.directory?(file_path)
            level = file_path.split(File::SEPARATOR).length
            outline.add_item(key, level, [])
          end
        end
        
        outline
      end
    end
  end
end
