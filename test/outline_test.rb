# frozen_string_literal: true
require 'test_helper'

class OutlineTest < Minitest::Test
  def test_initialize
    outline = HTOTConv::Outline.new
    refute_nil outline
  end

  def test_add_item
    outline = HTOTConv::Outline.new
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

  def test_validate
    outline = HTOTConv::Outline.new
    assert_raises(HTOTConv::Outline::ValidationError) { outline.validate }

    outline.key_header   = %w[H1 H2 H3]
    outline.value_header = %w[H(1) H(2)]
    outline.add_item("key", 1, %w[val1 val2])
    outline.validate

    outline.key_header = nil
    assert_raises(HTOTConv::Outline::ValidationError) { outline.validate }
    outline.key_header = [1, 2]
    assert_raises(HTOTConv::Outline::ValidationError) { outline.validate }
    outline.key_header = %w[H1 H2 H3]

    outline.value_header = nil
    assert_raises(HTOTConv::Outline::ValidationError) { outline.validate }
    outline.value_header = [1, 2]
    assert_raises(HTOTConv::Outline::ValidationError) { outline.validate }
    outline.value_header = %w[H(1) H(2)]

    outline.add_item("invalid")
    assert_raises(HTOTConv::Outline::ValidationError) { outline.validate }
  end

  def test_valid
    outline = HTOTConv::Outline.new
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

  def test_max_level
    outline = HTOTConv::Outline.new
    assert_raises { outline.max_level }

    outline.key_header = []
    outline.add_item("1", 1)
    assert_equal(1, outline.max_level)

    outline.add_item("1")
    assert_equal(1, outline.max_level)
    outline.add_item("1.1", 2)
    assert_equal(2, outline.max_level)

    outline.key_header = %w[H1]
    assert_equal(2, outline.max_level)
    outline.key_header = %w[H1 H2]
    assert_equal(2, outline.max_level)
    outline.key_header = %w[H1 H2 H3]
    assert_equal(3, outline.max_level)

    (1..25).each { |level| outline.add_item("level#{level}", level) }
    assert_equal(25, outline.max_level)
  end

  def test_max_value_length
    outline = HTOTConv::Outline.new
    assert_raises { outline.max_value_length }

    outline.value_header = []
    outline.add_item("1", 1)
    assert_equal(0, outline.max_value_length)

    outline.add_item("1", 1, %w[a])
    assert_equal(1, outline.max_value_length)
    outline.add_item("1", 1, %w[a b c])
    assert_equal(3, outline.max_value_length)

    outline.value_header = %w[H1 H2 H3]
    assert_equal(3, outline.max_value_length)
    outline.value_header = %w[H1 H2]
    assert_equal(3, outline.max_value_length)
    outline.value_header = %w[H1 H2 H3 H4]
    assert_equal(4, outline.max_value_length)
  end

  def test_to_tree
    outline = HTOTConv::Outline.new
    tree = outline.to_tree
    assert(tree.root?)
    assert_equal([], tree.to_a)

    outline.add_item("1", 1)
    tree = outline.to_tree
    assert_equal([["1", 1]], tree.to_a.map {|v| [v.item.key, v.item.level]})

    outline.add_item("1.1", 2)
    tree = outline.to_tree
    assert_equal([["1", 1]], tree.to_a.map {|v| [v.item.key, v.item.level]})
    assert_equal([["1.1", 2]], tree.to_a[0].to_a.map {|v| [v.item.key, v.item.level]})

    outline.add_item("1.2", 2)
    tree = outline.to_tree
    assert_equal([["1", 1]], tree.to_a.map {|v| [v.item.key, v.item.level]})
    assert_equal([["1.1", 2], ["1.2", 2]], tree.to_a[0].to_a.map {|v| [v.item.key, v.item.level]})

    outline.add_item("1.2.3", 3)
    tree = outline.to_tree
    assert_equal([["1", 1]], tree.to_a.map {|v| [v.item.key, v.item.level]})
    assert_equal([["1.1", 2], ["1.2", 2]], tree.to_a[0].to_a.map {|v| [v.item.key, v.item.level]})
    assert_equal([["1.2.3", 3]], tree.to_a[0].to_a[1].to_a.map {|v| [v.item.key, v.item.level]})

    outline.add_item("2", 1)
    tree = outline.to_tree
    assert_equal([["1", 1], ["2", 1]], tree.to_a.map {|v| [v.item.key, v.item.level]})
    assert_equal([["1.1", 2], ["1.2", 2]], tree.to_a[0].to_a.map {|v| [v.item.key, v.item.level]})
    assert_equal([["1.2.3", 3]], tree.to_a[0].to_a[1].to_a.map {|v| [v.item.key, v.item.level]})
  end
end

class OutlineItemTest < Minitest::Test
  def test_initialize
    item = HTOTConv::Outline::Item.new
    refute_nil item

    item = HTOTConv::Outline::Item.new('key', 1, %w[val1 val2])
    refute_nil item
    assert_equal("key", item.key)
    assert_equal(1, item.level)
    assert_equal(%w[val1 val2], item.value)
  end

  def test_validate
    item = HTOTConv::Outline::Item.new
    assert_raises(HTOTConv::Outline::ValidationError) { item.validate }

    item = HTOTConv::Outline::Item.new('key', 1, %w[val1 val2])
    item.validate

    item = HTOTConv::Outline::Item.new('key', 1.1, %w[val1 val2])
    assert_raises(HTOTConv::Outline::ValidationError) { item.validate }
    item = HTOTConv::Outline::Item.new('key', 0, %w[val1 val2])
    assert_raises(HTOTConv::Outline::ValidationError) { item.validate }
    item = HTOTConv::Outline::Item.new('key', "1", %w[val1 val2])
    assert_raises(HTOTConv::Outline::ValidationError) { item.validate }

    item = HTOTConv::Outline::Item.new('key', 1, [])
    item.validate
    item = HTOTConv::Outline::Item.new('key', 1, nil)
    assert_raises(HTOTConv::Outline::ValidationError) { item.validate }
    item = HTOTConv::Outline::Item.new('key', 1, {})
    assert_raises(HTOTConv::Outline::ValidationError) { item.validate }
    item = HTOTConv::Outline::Item.new('key', 1, (1..2))
    assert_raises(HTOTConv::Outline::ValidationError) { item.validate }
  end

  def test_valid
    item = HTOTConv::Outline::Item.new
    refute(item.valid?)

    item = HTOTConv::Outline::Item.new('key', 1, %w[val1 val2])
    assert(item.valid?)

    item = HTOTConv::Outline::Item.new('key', 1.1, %w[val1 val2])
    refute(item.valid?)
    item = HTOTConv::Outline::Item.new('key', 0, %w[val1 val2])
    refute(item.valid?)
    item = HTOTConv::Outline::Item.new('key', "1", %w[val1 val2])
    refute(item.valid?)

    item = HTOTConv::Outline::Item.new('key', 1, [])
    assert(item.valid?)
    item = HTOTConv::Outline::Item.new('key', 1, nil)
    refute(item.valid?)
    item = HTOTConv::Outline::Item.new('key', 1, {})
    refute(item.valid?)
    item = HTOTConv::Outline::Item.new('key', 1, (1..2))
    refute(item.valid?)
  end
end

class OutlineTreeTest < Minitest::Test
  def test_initialize
    root = ::HTOTConv::Outline::Tree.new
    assert_nil(root.parent)
    assert_nil(root.item)
    assert(root.root?)

    child = HTOTConv::Outline::Tree.new(HTOTConv::Outline::Item.new, root)
    assert_equal(root, child.parent)
    assert(root.root?)
    assert_equal(HTOTConv::Outline::Item.new, child.item)
    refute(child.root?)
  end

  def test_add
    root = ::HTOTConv::Outline::Tree.new
    assert_equal(root, root.add(1))
    assert_equal([1], root.to_a.map {|v| v.item })
    assert_equal(root, root << 2)
    assert_equal([1, 2], root.to_a.map {|v| v.item })
    assert_equal(root, root << 3 << 4)
    assert_equal([1, 2, 3, 4], root.to_a.map {|v| v.item })
  end

  def test_root
    root = ::HTOTConv::Outline::Tree.new
    assert_equal(root, root.root)

    child = ::HTOTConv::Outline::Tree.new(nil, root)
    assert_equal(root, child.root)

    grandchild = ::HTOTConv::Outline::Tree.new(nil, child)
    assert_equal(root, grandchild.root)
  end

  def test_next_prev
    root = ::HTOTConv::Outline::Tree.new
    root << 1 << 2 << 3
    children = root.to_a

    assert_nil(root.prev)
    assert_nil(root.next)

    assert_nil(children[0].prev)
    assert_equal(children[0], children[1].prev)
    assert_equal(children[1], children[2].prev)

    assert_equal(children[1], children[0].next)
    assert_equal(children[2], children[1].next)
    assert_nil(children[2].next)
  end

  def test_ancestors
    root = ::HTOTConv::Outline::Tree.new
    assert_equal([], root.ancestors.to_a)

    root << "1"
    root.to_a[0] << "1.1"
    root.to_a[0] << "1.2"
    root.to_a[0].to_a[1] << "1.2.1"

    assert_equal(["1.2", "1"], root.to_a[0].to_a[1].to_a[0].ancestors.map {|v| v.item})
    assert_equal(["1"], root.to_a[0].to_a[0].ancestors.map {|v| v.item})
  end

  def test_descendants
    root = ::HTOTConv::Outline::Tree.new
    assert_equal([], root.descendants.to_a)

    root << "1"
    root.to_a[0] << "1.1"
    root.to_a[0] << "1.2"
    root.to_a[0].to_a[1] << "1.2.1"
    root << "2"

    assert_equal(["1", "1.1", "1.2", "1.2.1", "2"], root.descendants.map {|v| v.item})
  end
end
