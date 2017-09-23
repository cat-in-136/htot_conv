require 'test_helper'

class HtmlListTest < Minitest::Test
  def test_initialize
    parser = ::HTOTConv::Parser::HtmlList.new
    refute_nil(parser)
  end

  def test_parse
    parser = ::HTOTConv::Parser::HtmlList.new
    outline = parser.parse(<<EOD)
<h1>**Dummy**</h1>
<ul>
  <li>1
    <ol>
      <li>1.1</li>
      <li>1.2
        <ul>
          <li>1.2.1</li>
        </ul>
      </li>
    </ol>
  </li>
</ul>
**Dummy**
EOD
    expected_outline = reference_outline
    expected_outline.key_header = expected_outline.value_header = []
    expected_outline.item.each do |item| item.value = [] end
    assert_equal(expected_outline, outline)

    outline = parser.parse(<<EOD)
<!-- omit the end tags -->
<ul>
  <li>1
    <ol>
      <li>1.1
      <li>1.2
        <ul>
          <li>1.2.1
        </ul>
    </ol>
</ul>
EOD
    assert_equal(expected_outline, outline)

    outline = parser.parse(<<EOD)
<!DOCTYPE html>
<!-- with misc -->
<html>
<head></head>
<body>
<h1>Test Case From Here</h1>
<ul>
  <li>1
    <ol>
      <!-- ignore comments and tags -->
      <li>1.<!-- *** --><b>1</b>
        <!-- --> <img src="dummy.jpg">
      </li>
    </ol>
    <ol>
      <!-- ignore characters just after end of list -->
      <li>1.2
        <ul>
          <li>1.2.1</li>
        </ul>
        ** Dummy **
      </li>
    </ol>
  </li>
</ul>
<footer>Test Case End</footer>
</body>
</html>
EOD
    assert_equal(expected_outline, outline)
  end
end
