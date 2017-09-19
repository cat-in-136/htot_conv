require 'test_helper'

class UtilTest < Minitest::Test
  def test_pad_array
    assert_equal([], ::HTOTConv::Util.pad_array([], 0))
    assert_raises(ArgumentError) { ::HTOTConv::Util.pad_array(nil, 0) }
    assert_raises(ArgumentError) { ::HTOTConv::Util.pad_array([1], 0) }
    assert_raises(ArgumentError) { ::HTOTConv::Util.pad_array([], -1) }

    assert_equal([nil, nil], ::HTOTConv::Util.pad_array([], 2))
    assert_equal([1, nil], ::HTOTConv::Util.pad_array([1], 2))
  end
end
