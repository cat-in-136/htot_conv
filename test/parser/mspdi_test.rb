# frozen_string_literal: true
require 'test_helper'

class MspdiTest < Minitest::Test
  def test_initialize
    parser = ::HTOTConv::Parser::Mspdi.new
    refute_nil(parser)
    assert_equal([], parser.option[:key_header])
  end

  def test_parse
    parser = ::HTOTConv::Parser::Mspdi.new(:key_header => %w[H1 H2 H3])
    outline = parser.parse(<<EOD)
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Project xmlns="http://schemas.microsoft.com/project">
  <Tasks>
    <Task>
      <UID>1</UID>
      <Name>1</Name>
      <OutlineLevel>1</OutlineLevel>
    </Task>
    <Task>
      <UID>2</UID>
      <Name>1.1</Name>
      <OutlineLevel>2</OutlineLevel>
    </Task>
    <Task>
      <UID>3</UID>
      <Name>1.2</Name>
      <OutlineLevel>2</OutlineLevel>
    </Task>
    <Task>
      <UID>4</UID>
      <Name>1.2.1</Name>
      <OutlineLevel>3</OutlineLevel>
    </Task>
  </Tasks>
</Project>
EOD
    expected_outline = reference_outline
    expected_outline.value_header = []
    expected_outline.item.each do |item| item.value = [] end
    assert_equal(expected_outline, outline)

    parser = ::HTOTConv::Parser::Mspdi.new(:key_header => %w[H1 H2 H3], :value_header => %w[UID])
    outline = parser.parse(<<EOD)
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Project xmlns="http://schemas.microsoft.com/project">
  <Tasks>
    <Task>
      <UID>1</UID>
      <Name>1</Name>
      <OutlineLevel>1</OutlineLevel>
    </Task>
    <Task>
      <UID>2</UID>
      <Name>1.1</Name>
      <OutlineLevel>2</OutlineLevel>
    </Task>
    <Task>
      <UID>3</UID>
      <Name>1.2</Name>
      <OutlineLevel>2</OutlineLevel>
    </Task>
    <Task>
      <UID>4</UID>
      <Name>1.2.1</Name>
      <OutlineLevel>3</OutlineLevel>
    </Task>
  </Tasks>
</Project>
EOD
    expected_outline = reference_outline
    expected_outline.value_header = %w[UID]
    expected_outline.item.each_with_index do |v,i|
      v.value = ["#{i + 1}"]
    end
    assert_equal(expected_outline, outline)
  end
end
