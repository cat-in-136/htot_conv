# frozen_string_literal: true
require 'test_helper'

class OpmlTest < Minitest::Test
  def test_initialize
    parser = ::HTOTConv::Parser::Opml.new
    refute_nil(parser)
    assert_equal([], parser.option[:key_header])
  end

  def test_parse
    parser = ::HTOTConv::Parser::Opml.new(:key_header => %w[H1 H2 H3])
    outline = parser.parse(<<EOD)
<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0">
  <head>
    <title>** Dummy **</title>
  </head>
  <body>
    <outline text="1" v1="1(1)" v2="1(2)">
      <outline text="1.1" v1="1.1(1)" v2="1.1(2)"/>
      <outline text="1.2" v1="1.2(1)" v2="1.2(2)">
        <outline text="1.2.1" v1="1.2.1(1)" v2="1.2.1(2)"/>
      </outline>
    </outline>
  </body>
</opml>
EOD
    expected_outline = reference_outline
    expected_outline.value_header = %w[v1 v2]
    assert_equal(expected_outline, outline)

    parser = ::HTOTConv::Parser::Opml.new
    outline = parser.parse(<<EOD)
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>** Dummy **</title>
  </head>
  <body>
    <outline text="1" v1="1(1)"/>
    <outline text="2" v1="2(1)" v2="2(2)"/>
    <outline text="3" v1="3(1)" v3="2(3)"/>
    <outline text="4"/>
  </body>
</opml>
EOD
    expected_outline = HTOTConv::Outline.new
    expected_outline.key_header = []
    expected_outline.value_header = %w[v1 v2 v3]
    expected_outline.add_item("1", 1, ["1(1)"])
    expected_outline.add_item("2", 1, ["2(1)", "2(2)"])
    expected_outline.add_item("3", 1, ["3(1)", nil, "2(3)"])
    expected_outline.add_item("4", 1, [])
    assert_equal(expected_outline, outline)
    assert_equal(expected_outline, outline)
  end
end
