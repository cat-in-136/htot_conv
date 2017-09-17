$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'outline2xlsx'

require 'minitest/autorun'

def reference_outline
  outline = Outline2xlsx::Outline.new
  outline.key_header   = %w[H1 H2 H3]
  outline.value_header = %w[H(1) H(2)]
  outline.add_item("1",     1, %w[1(1)     1(2)     ])
  outline.add_item("1.1",   2, %w[1.1(1)   1.1(2)   ])
  outline.add_item("1.2",   2, %w[1.2(1)   1.2(2)   ])
  outline.add_item("1.2.1", 3, %w[1.2.1(1) 1.2.1(2) ])
  outline
end

