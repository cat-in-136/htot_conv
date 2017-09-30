# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'htot_conv'

require 'minitest/autorun'

def reference_outline
  outline = HTOTConv::Outline.new
  outline.key_header   = %w[H1 H2 H3]
  outline.value_header = %w[H(1) H(2)]
  outline.add_item("1",     1, %w[1(1)     1(2)     ])
  outline.add_item("1.1",   2, %w[1.1(1)   1.1(2)   ])
  outline.add_item("1.2",   2, %w[1.2(1)   1.2(2)   ])
  outline.add_item("1.2.1", 3, %w[1.2.1(1) 1.2.1(2) ])
  outline
end

module MiniTest::Assertions
  def assert_exit_with(status) # :yield:
    ex = assert_raises(SystemExit) do
      yield
    end
    assert_equal(status, ex.status, "exit status mismatch")
    ex
  end
end

