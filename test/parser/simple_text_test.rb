# frozen_string_literal: true
require 'test_helper'

class SimpleTextTest < Minitest::Test
  def test_initialize
    parser = ::HTOTConv::Parser::SimpleText.new
    assert_equal("\t", parser.option[:indent])
    assert_nil(parser.option[:delimiter])
    assert_equal([], parser.option[:value_header])
    refute(parser.option[:preserve_empty_line])

    parser = ::HTOTConv::Parser::SimpleText.new({
      :indent => '  ',
      :delimiter => "\t",
      :value_header => %w[H(1) H(2)],
      :preserve_empty_line => true,
    })
    assert_equal("  ", parser.option[:indent])
    assert_equal("\t", parser.option[:delimiter])
    assert_equal(%w[H(1) H(2)], parser.option[:value_header])
    assert(parser.option[:preserve_empty_line])
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
    assert_equal(expected_outline, outline)

    parser = ::HTOTConv::Parser::SimpleText.new({:indent => '  ', :delimiter => /\s*,\s*/})
    outline = parser.parse(<<EOD)
1           , 1(1),     1(2)
  1.1       , 1.1(1),   1.1(2)
  1.2       , 1.2(1),   1.2(2)
    1.2.1   , 1.2.1(1), 1.2.1(2)

EOD
    expected_outline = reference_outline
    expected_outline.key_header = expected_outline.value_header = []
    assert_equal(expected_outline, outline)

    parser = ::HTOTConv::Parser::SimpleText.new({:indent => '  ', :delimiter => /\s*,\s*/, :preserve_empty_line => true, :value_header => %w[H(1) H(2)]})
    outline = parser.parse(<<EOD)
1           , 1(1),     1(2)
  1.1       , 1.1(1),   1.1(2)
  1.2       , 1.2(1),   1.2(2)
    1.2.1   , 1.2.1(1), 1.2.1(2)

EOD
    expected_outline = reference_outline
    expected_outline.add_item(nil, 1, [])
    expected_outline.key_header = []
    assert_equal(expected_outline, outline)
  end
end
