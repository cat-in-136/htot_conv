# frozen_string_literal: true
require 'htot_conv/parser/base'

module HTOTConv
  module Parser
    class DirTree < Base
      def self.option_help
        {
          :glob_pattern => {
            :default => "**/*",
            :pat => String,
            :desc => "globbing pattern (default: \"**/*\")",
          },
        }
      end

      def parse(input=Dir.pwd)
        outline = HTOTConv::Outline.new
        outline.key_header = []
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
        end

        outline_item.sort.each do |file_path|
          key = File.basename(file_path)
          level = file_path.split(File::SEPARATOR).length
          outline.add_item(key, level, [])
        end

        outline
      end
    end
  end
end
