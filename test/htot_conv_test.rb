# frozen_string_literal: true
require 'test_helper'

require 'tempfile'
require 'zip'

class HTOTConvTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::HTOTConv::VERSION
  end

  def test_convert
    has_xl_worksheets_sheet1_xml = false

    f = Tempfile.new(['test', '.xlsx'])
    begin
      HTOTConv.convert(<<EOD, :simple_text, f, :xlsx_type0, {:indent => '  ', :delimiter => /\s*,\s*/})
1           , 1(1),     1(2)
  1.1       , 1.1(1),   1.1(2)
  1.2       , 1.2(1),   1.2(2)
    1.2.1   , 1.2.1(1), 1.2.1(2)
EOD
      f.rewind

      Zip::File.open(f) do |zf|
        zf.each do |entry|
          if (entry.name == 'xl/worksheets/sheet1.xml')
            has_xl_worksheets_sheet1_xml = true
            sheet = Nokogiri::XML.parse(entry.get_input_stream)
            textized_row = (1..5).map { |row| sheet.css("row[r='#{row}'] c").map {|v| v.text }.join(",") }
            assert_empty(sheet.css("row[r='6']"))

            assert_equal(",Outline Level,,", textized_row[0])
            assert_equal("1,1,1(1),1(2)", textized_row[1])
            assert_equal("1.1,2,1.1(1),1.1(2)", textized_row[2])
            assert_equal("1.2,2,1.2(1),1.2(2)", textized_row[3])
            assert_equal("1.2.1,3,1.2.1(1),1.2.1(2)", textized_row[4])
          end
        end
      end
    ensure
      f.close!
    end

    assert(has_xl_worksheets_sheet1_xml)
  end

  def test_parser_generator_types
    [::HTOTConv::Parser, ::HTOTConv::Generator].each do |klass|
      klass.types.each do |type|
        assert_kind_of(Symbol, type)
        assert_kind_of(Class, klass.const_get(Rinne.camelize(type.to_s)))
      end
    end
  end

end
