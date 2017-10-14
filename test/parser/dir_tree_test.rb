# frozen_string_literal: true
require 'test_helper'

require 'fakefs/safe'

class DirTreeTest < Minitest::Test
  include FakeFS

  def test_initialize
    parser = ::HTOTConv::Parser::DirTree.new
    refute_nil(parser)
    assert_equal([], parser.option[:key_header])
    assert_equal("**/*", parser.option[:glob_pattern])
    assert_equal("", parser.option[:dir_indicator])
  end

  def test_parse
    FakeFS do
      FileUtils.mkdir_p(File.join(Dir.pwd, *%w[path to test fs 1 1.1]))
      FileUtils.mkdir_p(File.join(Dir.pwd, *%w[path to test fs 1 1.2]))
      FileUtils.touch  (File.join(Dir.pwd, *%w[path to test fs 1 1.2 1.2.1]))

      parser = ::HTOTConv::Parser::DirTree.new(:key_header => %w[H1 H2 H3])
      outline = parser.parse("path/to/test/fs")
      expected_outline = reference_outline
      expected_outline.value_header = []
      expected_outline.item.each do |item| item.value = [] end
      assert_equal(expected_outline, outline)
      
      outline = parser.parse("path/to/test/fs/")
      assert_equal(expected_outline, outline)

      parser = ::HTOTConv::Parser::DirTree.new
      outline = parser.parse("path/to/test/fs")
      expected_outline = reference_outline
      expected_outline.key_header = expected_outline.value_header = []
      expected_outline.item.each do |item| item.value = [] end
      assert_equal(expected_outline, outline)

      outline = parser.parse("path/to/test/fs/")
      assert_equal(expected_outline, outline)

      FileUtils.mkdir_p(File.join(Dir.pwd, *%w[path to test fs 2]))
      parser = ::HTOTConv::Parser::DirTree.new(:glob_pattern => '**/1*')
      outline = parser.parse("path/to/test/fs/")
      assert_equal(expected_outline, outline)

      expected_outline = HTOTConv::Outline.new
      expected_outline.key_header = expected_outline.value_header = []
      expected_outline.add_item("1",     1, [])
      expected_outline.add_item("1.2",   2, [])
      expected_outline.add_item("1.2.1", 3, [])
      parser = ::HTOTConv::Parser::DirTree.new(:glob_pattern => '**/1.2.1')
      outline = parser.parse("path/to/test/fs")
      assert_equal(expected_outline, outline)

      expected_outline = HTOTConv::Outline.new
      expected_outline.key_header = expected_outline.value_header = []
      expected_outline.add_item("1/",    1, [])
      expected_outline.add_item("1.2/",  2, [])
      expected_outline.add_item("1.2.1", 3, [])
      parser = ::HTOTConv::Parser::DirTree.new(:glob_pattern => '**/1.2.1', :dir_indicator => '/')
      outline = parser.parse("path/to/test/fs")
      assert_equal(expected_outline, outline)
    end
  end
end
