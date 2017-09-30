# frozen_string_literal: true
require 'test_helper'

class SimpleTextTest < Minitest::Test
  def test_initialize
    parser = ::HTOTConv::Parser::SimpleText.new
    assert_equal("\t", parser.option[:indent])
    assert_nil(parser.option[:delimiter])
    assert_equal([], parser.option[:value_header])

    parser = ::HTOTConv::Parser::SimpleText.new({
      :indent => '  ',
      :delimiter => "\t",
      :value_header => %w[H(1) H(2)],
    })
    assert_equal("  ", parser.option[:indent])
    assert_equal("\t", parser.option[:delimiter])
    assert_equal(%w[H(1) H(2)], parser.option[:value_header])
  end

  def test_parse
    parser = ::HTOTConv::Parser::SimpleText.new({:indent => '  ', :delimiter => /\s*,\s*/, :value_header => %w[H(1) H(2)]})
    outline = parser.parse(<<EOD)
1           , 1(1),     1(2)
  1.1       , 1.1(1),   1.1(2)
  1.2       , 1.2(1),   1.2(2)
    1.2.1   , 1.2.1(1), 1.2.1(2)
EOD
    expected_outline = reference_outline
    expected_outline.key_header = []
    expected_outline.value_header = %w[H(1) H(2)]
    assert_equal(expected_outline, outline)
  end
end
