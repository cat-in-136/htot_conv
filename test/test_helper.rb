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

def wrt_worksheet
  wb = RubyXL::Workbook.new
  yield wb[0]
end

def range_to_a(range)
  range = RubyXL::Reference.new(*range) unless range.kind_of?(RubyXL::Reference)

  range.row_range.map do |row_num|
    range.col_range.map do |col_num|
      if block_given?
        yield row_num.to_i, col_num.to_i
      else
        [row_num.to_i, col_num.to_i]
      end
    end
  end
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

