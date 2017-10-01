# frozen_string_literal: true
require 'test_helper'

require 'tempfile'

class XlsxType2Test < Minitest::Test
  def test_output_worksheet
    gen = ::HTOTConv::Generator::XlsxType2.new(reference_outline)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal([
          ["H1", "H2", "H3",    "H(1)",     "H(2)",     ],
          [1,    nil,  nil,     "1(1)",     "1(2)",     ],
          [nil,  1.1,  nil,     "1.1(1)",   "1.1(2)",   ],
          [nil,  1.2,  nil,     "1.2(1)",   "1.2(2)",   ],
          [nil,  nil,  "1.2.1", "1.2.1(1)", "1.2.1(2)", ],
        ].flatten, ws["A1:E5"].map {|v| v.value })

        assert_empty(ws.send(:merged_cells).to_a)
      end
    end
  end

  def test_output_worksheet_with_integrate_cells
    gen = ::HTOTConv::Generator::XlsxType2.new(reference_outline, :integrate_cells => :colspan)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal(%w[A2:C2 B3:C3 B4:C4], ws.send(:merged_cells).to_a.sort)
      end
    end

    gen = ::HTOTConv::Generator::XlsxType2.new(reference_outline, :integrate_cells => :rowspan)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal(%w[A2:A5 B4:B5], ws.send(:merged_cells).to_a.sort)
      end
    end
  end

end
