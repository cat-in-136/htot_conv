# frozen_string_literal: true
require 'test_helper'

require 'tempfile'

class XlsxType3Test < Minitest::Test
  def test_output_worksheet
    gen = ::HTOTConv::Generator::XlsxType3.new(reference_outline)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal([
        ["H1", "H(1)", nil,      nil,        "H(2)",     ],
        ["1",  "1(1)", nil,      nil,        "1(2)",     ],
        [nil,  "1.1",  "1.1(1)", nil,        "1.1(2)",   ],
        [nil,  "1.2",  "1.2(1)", nil,        "1.2(2)",   ],
        [nil,  nil,    "1.2.1",  "1.2.1(1)", "1.2.1(2)", ],
      ], range_to_a("A1:E5") { |r,c| ws[r][c].value })

      assert_empty(ws.merged_cells.to_a)
    end

    outline = ::HTOTConv::Outline.new
    outline.add_item("1", 1, [])
    outline.add_item("1.1", 2, %w[1.1(1)])
    outline.key_header = %w[H1]
    outline.value_header = %w[H(1)]
    gen = ::HTOTConv::Generator::XlsxType3.new(outline)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal([
        ["H1", "H(1)", nil,    ],
        ["1",  nil,    nil,    ],
        [nil,  "1.1",  "1.1(1)"],
      ], range_to_a("A1:C3") { |r,c| ws[r][c].value })

      assert_empty(ws.merged_cells.to_a)
    end

    outline.item.each { |v| v.value = [] }
    outline.value_header = []
    gen = ::HTOTConv::Generator::XlsxType3.new(outline)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal([
        ["H1", nil,  ],
        ["1",  nil,  ],
        [nil,  "1.1",],
      ], range_to_a("A1:B3") { |r,c| ws[r][c].value })

      assert_empty(ws.merged_cells.to_a)
    end
  end

  def test_output_worksheet_with_integrate_cells
    gen = ::HTOTConv::Generator::XlsxType3.new(reference_outline, :integrate_cells => :colspan)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal(%w[B1:D1 B2:D2 C3:D3 C4:D4], ws.merged_cells.to_a.map {|v| v.ref.to_s }.sort)
    end

    gen = ::HTOTConv::Generator::XlsxType3.new(reference_outline, :integrate_cells => :rowspan)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal(%w[A2:A5 B4:B5], ws.merged_cells.to_a.map {|v| v.ref.to_s }.sort)
    end

    gen = ::HTOTConv::Generator::XlsxType3.new(reference_outline, :integrate_cells => :both)
    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)

      assert_equal(%w[A2:A5 B1:D1 B2:D2 B4:B5 C3:D3 C4:D4], ws.merged_cells.to_a.map {|v| v.ref.to_s }.sort)
    end
  end

end
