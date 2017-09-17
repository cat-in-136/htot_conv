require 'test_helper'

require 'tempfile'

class XlsxType0Test < Minitest::Test
  def test_output
    gen = ::Outline2xlsx::Generator::XlsxType0.new(
      {
        :key_header => %w[H1 H2 H3],
        :value_header => %w[H(1) H(2)],
        :item => [
          { :key => "1",     :level => 1, :value => %w[1(1)     1(2)     ] },
          { :key => "1.1",   :level => 2, :value => %w[1.1(1)   1.1(2)   ] },
          { :key => "1.2",   :level => 2, :value => %w[1.2(1)   1.2(2)   ] },
          { :key => "1.2.1", :level => 3, :value => %w[1.2.1(1) 1.2.1(2) ] },
        ],
      }
    )
    refute_nil(gen.instance_variable_get(:@data))

    Tempfile.open do |f|
      gen.output(f)
      assert(f.size > 150)
    end
  end

  def test_output_worksheet
    gen = ::Outline2xlsx::Generator::XlsxType0.new(
      {
        :key_header => %w[H1 H2 H3],
        :value_header => %w[H(1) H(2)],
        :item => [
          { :key => "1",     :level => 1, :value => %w[1(1)     1(2)     ] },
          { :key => "1.1",   :level => 2, :value => %w[1.1(1)   1.1(2)   ] },
          { :key => "1.2",   :level => 2, :value => %w[1.2(1)   1.2(2)   ] },
          { :key => "1.2.1", :level => 3, :value => %w[1.2.1(1) 1.2.1(2) ] },
        ],
      }
    )

    p = Axlsx::Package.new
    p.workbook do |wb|
      wb.add_worksheet() do |ws|
        gen.output_to_worksheet(ws)

        assert_equal([
          ['H1',    'Level',	'H(1)',	    'H(2)',     ],
          [1,       1,        '1(1)',	    '1(2)',     ],
          [1.1,     2,        '1.1(1)',   '1.1(2)',   ],
          [1.2,     2,        '1.2(1)',   '1.2(2)',   ],
          ['1.2.1', 3,        '1.2.1(1)',	'1.2.1(2)', ],
        ].flatten, ws["A1:D5"].map {|v| v.value })
      end
    end
  end
end
