require 'test_helper'

class UtilTest < Minitest::Test
  def test_pad_array
    assert_equal([], ::Outline2xlsx::Util.pad_array([], 0))
    assert_raises(ArgumentError) { ::Outline2xlsx::Util.pad_array(nil, 0) }
    assert_raises(ArgumentError) { ::Outline2xlsx::Util.pad_array([1], 0) }
    assert_raises(ArgumentError) { ::Outline2xlsx::Util.pad_array([], -1) }

    assert_equal([nil, nil], ::Outline2xlsx::Util.pad_array([], 2))
    assert_equal([1, nil], ::Outline2xlsx::Util.pad_array([1], 2))
  end
end
