module Outline2xlsx
  module Generator
    class Base
      def initialize(data)
        @data = data
      end

      def output(outputfile)
        raise NotImplementedError.new("#{self.class.name}.#{__method__} is an abstract method.")
      end
    end

    class XlsxBase < Base
      def output_to_worksheet(ws)
        raise NotImplementedError.new("#{self.class.name}.#{__method__} is an abstract method.")
      end

      def output(outputfile)
        p = Axlsx::Package.new
        p.workbook do |wb|
          wb.add_worksheet do |ws|
            output_to_worksheet(ws)
          end
        end
        p.serialize(outputfile)
      end
    end
  end
end
