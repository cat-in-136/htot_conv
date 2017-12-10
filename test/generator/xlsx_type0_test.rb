# frozen_string_literal: true
require 'test_helper'

require 'tempfile'

class XlsxType0Test < Minitest::Test
  def test_output_worksheet
    gen = ::HTOTConv::Generator::XlsxType0.new(reference_outline)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal([
        ['H1',    'Outline Level',	'H(1)',	    'H(2)',     ],
        ['1',     1,                '1(1)',	    '1(2)',     ],
        ['1.1',   2,                '1.1(1)',   '1.1(2)',   ],
        ['1.2',   2,                '1.2(1)',   '1.2(2)',   ],
        ['1.2.1', 3,                '1.2.1(1)',	'1.2.1(2)', ],
      ], range_to_a("A1:D5") { |r,c| ws[r][c].value })
    end
  end
end
