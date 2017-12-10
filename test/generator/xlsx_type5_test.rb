# frozen_string_literal: true
require 'test_helper'

require 'tempfile'

class XlsxType5Test < Minitest::Test
  def test_output_worksheet
    gen = ::HTOTConv::Generator::XlsxType5.new(reference_outline)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal([
        ["H1", "H2",  "H3",    "H(1)",     "H(2)",     ],
        ["1",  "1.1", nil,     "1.1(1)",   "1.1(2)",   ],
        ["1",  "1.2", "1.2.1", "1.2.1(1)", "1.2.1(2)", ],
      ], range_to_a("A1:E3") { |r,c| ws[r][c].value })

      assert_empty(ws.merged_cells.to_a)
    end
  end

  def test_output_worksheet_with_integrate_cells
    gen = ::HTOTConv::Generator::XlsxType5.new(reference_outline, :integrate_cells => :colspan)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal(%w[B2:C2], ws.merged_cells.to_a.map {|v| v.ref.to_s }.sort)
    end
  end
end
