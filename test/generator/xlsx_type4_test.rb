# frozen_string_literal: true
require 'test_helper'

require 'tempfile'

class XlsxType4Test < Minitest::Test
  def test_output_worksheet
    gen = ::HTOTConv::Generator::XlsxType4.new(reference_outline)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal([
          ["H1", "H2", "H3",    "H(1)",     "H(2)",     ],
          [1,    1.1,  nil,     "1.1(1)",   "1.1(2)",   ],
          [nil,  1.2, "1.2.1",  "1.2.1(1)", "1.2.1(2)", ],
        ].flatten, ws["A1:E3"].map {|v| v.value })

        assert_empty(ws.send(:merged_cells).to_a)
      end
    end

    outline = HTOTConv::Outline.new
    outline.key_header   = %w[H1 H2 H3]
    outline.value_header = []
    outline.add_item("1",     1, [])
    outline.add_item("1.1",   2, [])
    outline.add_item("1.1.1", 3, [])
    outline.add_item("1.1.2", 3, [])
    gen = ::HTOTConv::Generator::XlsxType4.new(outline)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal([
          ["H1", "H2", "H3",  ],
          [1,    1.1, "1.1.1",],
          [nil,  nil, "1.1.2",],
        ].flatten, ws["A1:C3"].map {|v| v.value })

        assert_empty(ws.send(:merged_cells).to_a)
      end
    end

  end

  def test_output_worksheet_with_integrate_cells
    gen = ::HTOTConv::Generator::XlsxType4.new(reference_outline, :integrate_cells => :colspan)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal(%w[B2:C2], ws.send(:merged_cells).to_a.sort)
      end
    end

    gen = ::HTOTConv::Generator::XlsxType4.new(reference_outline, :integrate_cells => :rowspan)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal(%w[A2:A3], ws.send(:merged_cells).to_a.sort)
      end
    end
    
    gen = ::HTOTConv::Generator::XlsxType4.new(reference_outline, :integrate_cells => :both)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal(%w[A2:A3 B2:C2], ws.send(:merged_cells).to_a.sort)
      end
    end

    outline = HTOTConv::Outline.new
    outline.key_header   = %w[H1 H2 H3]
    outline.value_header = []
    outline.add_item("1",     1, [])
    outline.add_item("1.1",   2, [])
    outline.add_item("1.1.1", 3, [])
    outline.add_item("1.1.2", 3, [])
    gen = ::HTOTConv::Generator::XlsxType4.new(outline, :integrate_cells => :both)
    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet do |ws|
        gen.output_to_worksheet(ws)

        assert_equal([
          ["H1", "H2", "H3",  ],
          [1,    1.1, "1.1.1",],
          [nil,  nil, "1.1.2",],
        ].flatten, ws["A1:C3"].map {|v| v.value })

        assert_equal(%w[A2:A3 B2:B3], ws.send(:merged_cells).to_a.sort)
      end
    end
  end
end
