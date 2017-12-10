# frozen_string_literal: true
require 'test_helper'

require 'tempfile'

class XlsxType1Test < Minitest::Test
  def test_output_worksheet
    gen = ::HTOTConv::Generator::XlsxType1.new(reference_outline)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal([
        ['H1',    'H(1)',     'H(2)',     ],
        ['1',     '1(1)',     '1(2)',     ],
        ['1.1',   '1.1(1)',   '1.1(2)',   ],
        ['1.2',   '1.2(1)',   '1.2(2)',   ],
        ['1.2.1', '1.2.1(1)', '1.2.1(2)', ],
      ], range_to_a("A1:C5") { |r,c| ws[r][c].value })
    end
  end

  def test_output_worksheet_with_outline_rows
    gen = ::HTOTConv::Generator::XlsxType1.new(reference_outline, :outline_rows => true)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal([nil, nil, 1, 1, 2], ws.map { |v| v.outline_level })
    end
  end
end
