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
      end
    end
  end
end
