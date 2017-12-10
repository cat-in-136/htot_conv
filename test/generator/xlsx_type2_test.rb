# frozen_string_literal: true
require 'test_helper'

require 'tempfile'

class XlsxType2Test < Minitest::Test
  def test_output_worksheet
    gen = ::HTOTConv::Generator::XlsxType2.new(reference_outline)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal([
        ["H1", "H2",  "H3",    "H(1)",     "H(2)",     ],
        ["1",  nil,   nil,     "1(1)",     "1(2)",     ],
        [nil,  "1.1", nil,     "1.1(1)",   "1.1(2)",   ],
        [nil,  "1.2", nil,     "1.2(1)",   "1.2(2)",   ],
        [nil,  nil,   "1.2.1", "1.2.1(1)", "1.2.1(2)", ],
      ], range_to_a("A1:E5") { |r,c| ws[r][c].value })

      assert_empty(ws.merged_cells.to_a)
    end
  end

  def test_output_worksheet_with_integrate_cells
    gen = ::HTOTConv::Generator::XlsxType2.new(reference_outline, :integrate_cells => :colspan)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal(%w[A2:C2 B3:C3 B4:C4], ws.merged_cells.to_a.map {|v| v.ref.to_s }.sort)
    end

    gen = ::HTOTConv::Generator::XlsxType2.new(reference_outline, :integrate_cells => :rowspan)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal(%w[A2:A5 B4:B5], ws.merged_cells.to_a.map {|v| v.ref.to_s }.sort)
    end
  end

  def test_output_worksheet_with_outline_rows
    gen = ::HTOTConv::Generator::XlsxType2.new(reference_outline, :outline_rows => true)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal([nil, nil, 1, 1, 2], ws.map { |v| v.outline_level })
    end
  end

end
