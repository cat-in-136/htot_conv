# frozen_string_literal: true
require 'test_helper'

class XlsxBaseTest < Minitest::Test
  def test_output_worksheet
    gen = ::HTOTConv::Generator::XlsxBase.new(reference_outline)
    class << gen
      def output_to_worksheet(ws)
        @output_to_worksheet_was_called_with = ws
      end
    end

    assert_equal(reference_outline, gen.instance_variable_get(:@data))
    assert_equal({:shironuri => false}, gen.instance_variable_get(:@option))

    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)
      
      assert_equal(ws, gen.instance_variable_get(:@output_to_worksheet_was_called_with))
    end
  end

  def test_output_worksheet_with_shironuri
    gen = ::HTOTConv::Generator::XlsxBase.new(reference_outline, :shironuri => true)
    class << gen
      def output_to_worksheet(ws)
        shironuri(ws.workbook, ws)
      end
    end

    assert_equal(reference_outline, gen.instance_variable_get(:@data))
    assert_equal({:shironuri => true}, gen.instance_variable_get(:@option))

    wrt_worksheet do |ws|
      gen.output_to_worksheet(ws)
      
      assert_equal(1, ws.cols.length)
      (0..0x4000).each do |x|
        assert_equal('ffffff', ws.get_column_fill(x))
      end
    end
  end
end
