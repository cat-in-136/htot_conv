# frozen_string_literal: true
require 'test_helper'

require 'tempfile'

class XlsxType3Test < Minitest::Test
  def test_output_worksheet
    gen = ::HTOTConv::Generator::XlsxType3.new(reference_outline)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal([
          ["H1", "H(1)", nil,      nil,        "H(2)",     ],
          [1,    "1(1)", nil,      nil,        "1(2)",     ],
          [nil,  1.1,    "1.1(1)", nil,        "1.1(2)",   ],
          [nil,  1.2,    "1.2(1)", nil,        "1.2(2)",   ],
          [nil,  nil,    "1.2.1",  "1.2.1(1)", "1.2.1(2)", ],
        ].flatten, ws["A1:E5"].map {|v| v.value })

        assert_empty(ws.send(:merged_cells).to_a)
      end
    end

    outline = ::HTOTConv::Outline.new
    outline.add_item("1", 1, [])
    outline.add_item("1.1", 2, %w[1.1(1)])
    outline.key_header = %w[H1]
    outline.value_header = %w[H(1)]
    gen = ::HTOTConv::Generator::XlsxType3.new(outline)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal([
          ["H1", "H(1)", nil,    ],
          [1,    nil,    nil,    ],
          [nil,  1.1,    "1.1(1)"],
        ].flatten, ws["A1:C3"].map {|v| v.value })

        assert_empty(ws.send(:merged_cells).to_a)
      end
    end

    outline.item.each { |v| v.value = [] }
    outline.value_header = []
    gen = ::HTOTConv::Generator::XlsxType3.new(outline)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal([
          ["H1", nil,],
          [1,    nil,],
          [nil,  1.1,],
        ].flatten, ws["A1:B3"].map {|v| v.value })

        assert_empty(ws.send(:merged_cells).to_a)
      end
    end
  end

  def test_output_worksheet_with_integrate_cells
    gen = ::HTOTConv::Generator::XlsxType3.new(reference_outline, :integrate_cells => :colspan)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal(%w[B1:D1 B2:D2 C3:D3 C4:D4], ws.send(:merged_cells).to_a.sort)
      end
    end

    gen = ::HTOTConv::Generator::XlsxType3.new(reference_outline, :integrate_cells => :rowspan)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal(%w[A2:A5 B4:B5], ws.send(:merged_cells).to_a.sort)
      end
    end

    gen = ::HTOTConv::Generator::XlsxType3.new(reference_outline, :integrate_cells => :both)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal(%w[A2:A5 B1:D1 B2:D2 B4:B5 C3:D3 C4:D4], ws.send(:merged_cells).to_a.sort)
      end
    end
  end

end