require 'test_helper'

class SimpleTextTest < Minitest::Test
  def test_initialize
    parser = ::Outline2xlsx::Parser::SimpleText.new
    assert_equal("\t", parser.option[:indent])
    assert_nil(parser.option[:delimiter])

    parser = ::Outline2xlsx::Parser::SimpleText.new({:indent => '  ', :delimiter => "\t"})
    assert_equal("  ", parser.option[:indent])
    assert_equal("\t", parser.option[:delimiter])
  end

  def test_parse
    parser = ::Outline2xlsx::Parser::SimpleText.new({:indent => '  ', :delimiter => /\s*,\s*/})
    outline = parser.parse(<<EOD)
1           , 1(1),     1(2)
  1.1       , 1.1(1),   1.1(2)
  1.2       , 1.2(1),   1.2(2)
    1.2.1   , 1.2.1(1), 1.2.1(2)
EOD
    expected_outline = reference_outline
    expected_outline.key_header = expected_outline.value_header = []
    assert_equal(expected_outline, outline)
  end
end
