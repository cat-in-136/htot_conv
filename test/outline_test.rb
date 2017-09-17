require 'test_helper'

class OutlineTest < Minitest::Test
  def test_initialize
    outline = Outline2xlsx::Outline.new
    refute_nil outline
  end

  def test_add_item
    outline = Outline2xlsx::Outline.new
    outline.add_item("key", 1, %w[val1 val2])
    assert_equal(1, outline.item.length)
    assert_equal("key", outline.item[0].key)
    assert_equal(1, outline.item[0].level)
    assert_equal(%w[val1 val2], outline.item[0].value)

    outline.add_item("key2", 1, %w[val1 val2])
    assert_equal(2, outline.item.length)
    assert_equal("key", outline.item[0].key)
    assert_equal("key2", outline.item[1].key)
  end

  def test_valid
    outline = Outline2xlsx::Outline.new
    refute(outline.valid?)

    outline.key_header   = %w[H1 H2 H3]
    outline.value_header = %w[H(1) H(2)]
    outline.add_item("key", 1, %w[val1 val2])
    assert(outline.valid?)

    outline.key_header = nil
    refute(outline.valid?)
    outline.key_header = [1, 2]
    refute(outline.valid?)
    outline.key_header = %w[H1 H2 H3]

    outline.value_header = nil
    refute(outline.valid?)
    outline.value_header = [1, 2]
    refute(outline.valid?)
    outline.value_header = %w[H(1) H(2)]

    outline.add_item("invalid")
    refute(outline.valid?)
  end
end

class OutlineItemTest < Minitest::Test
  def test_initialize
    item = Outline2xlsx::Outline::Item.new
    refute_nil item

    item = Outline2xlsx::Outline::Item.new('key', 1, %w[val1 val2])
    refute_nil item
    assert_equal("key", item.key)
    assert_equal(1, item.level)
    assert_equal(%w[val1 val2], item.value)
  end

  def test_valid
    item = Outline2xlsx::Outline::Item.new
    refute(item.valid?)

    item = Outline2xlsx::Outline::Item.new('key', 1, %w[val1 val2])
    assert(item.valid?)

    item = Outline2xlsx::Outline::Item.new('key', 1.1, %w[val1 val2])
    refute(item.valid?)
    item = Outline2xlsx::Outline::Item.new('key', 0, %w[val1 val2])
    refute(item.valid?)
    item = Outline2xlsx::Outline::Item.new('key', "1", %w[val1 val2])
    refute(item.valid?)

    item = Outline2xlsx::Outline::Item.new('key', 1, [])
    assert(item.valid?)
    item = Outline2xlsx::Outline::Item.new('key', 1, nil)
    refute(item.valid?)
    item = Outline2xlsx::Outline::Item.new('key', 1, {})
    refute(item.valid?)
    item = Outline2xlsx::Outline::Item.new('key', 1, (1..2))
    refute(item.valid?)
  end
end
