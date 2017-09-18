require 'test_helper'

require 'tempfile'

class XlsxType1Test < Minitest::Test
  def test_output_worksheet
    gen = ::Outline2xlsx::Generator::XlsxType1.new(reference_outline)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal([
          ['H1',    'H(1)',	    'H(2)',     ],
          [1,       '1(1)',	    '1(2)',     ],
          [1.1,     '1.1(1)',   '1.1(2)',   ],
          [1.2,     '1.2(1)',   '1.2(2)',   ],
          ['1.2.1', '1.2.1(1)',	'1.2.1(2)', ],
        ].flatten, ws["A1:C5"].map {|v| v.value })
      end
    end
  end
end
