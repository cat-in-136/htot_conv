# frozen_string_literal: true
require 'test_helper'

require 'htot_conv'
require 'htot_conv/cli'

require 'tempfile'
require 'zip'

class CLITest < Minitest::Test

  def test_main_default
    fin = Tempfile.new(['outline', '.txt'])
    fout = Tempfile.new(['outline', '.xlsx'])
    begin
      has_xl_worksheets_sheet1_xml = false

      fin << <<EOD
1, 1(1), 1(2)
  1.1, 1.1(1), 1.1(2)
  1.2, 1.2(1), 1.2(2)
    1.2.1, 1.2.1(1), 1.2.1(2)
EOD
      fin.rewind

      out, err = capture_io do
        HTOTConv::CLI.main(['-t', 'xlsx-type0', '--from-indent', '  ', '--from-delimiter', ', ', fin.path, fout.path])
      end
      assert_equal("", out)
      print err unless err.empty? #assert_equal("", err)

      Zip::File.open(fout) do |zf|
        zf.each do |entry|
          if (entry.name == 'xl/worksheets/sheet1.xml')
            has_xl_worksheets_sheet1_xml = true
            sheet = Nokogiri::XML.parse(entry.get_input_stream)
            textized_row = (1..5).map { |row| sheet.css("row[r='#{row}'] c").map {|v| v.text }.join(",") }
            assert_empty(sheet.css("row[r='6']"))

            assert_equal(",Level,,", textized_row[0])
            assert_equal("1,1,1(1),1(2)", textized_row[1])
            assert_equal("1.1,2,1.1(1),1.1(2)", textized_row[2])
            assert_equal("1.2,2,1.2(1),1.2(2)", textized_row[3])
            assert_equal("1.2.1,3,1.2.1(1),1.2.1(2)", textized_row[4])
          end
        end
      end
      assert(has_xl_worksheets_sheet1_xml)

      has_xl_worksheets_sheet1_xml = false
      fin.rewind
      fout.rewind

      fin << <<EOD
President
.VP Marketing
..Manager
..Manager
.VP Production
..Manager
..Manager
.VP Sales
..Manager
..Manager
EOD
      fin.rewind

      out, err = capture_io do
        HTOTConv::CLI.main(%w[-f simple_text --from-indent=. -t xlsx_type2].concat([fin.path, fout.path]))
      end
      assert_equal("", out)
      print err unless err.empty? #assert_equal("", err)

      Zip::File.open(fout) do |zf|
        zf.each do |entry|
          if (entry.name == 'xl/worksheets/sheet1.xml')
            has_xl_worksheets_sheet1_xml = true
            sheet = Nokogiri::XML.parse(entry.get_input_stream)
            textized_row = (1..11).map { |row| sheet.css("row[r='#{row}'] c").map {|v| v.text }.join(",") }
            assert_empty(sheet.css("row[r='12']"))

            assert_equal(",,",              textized_row[0])
            assert_equal("President,,",     textized_row[1])
            assert_equal(",VP Marketing,",  textized_row[2])
            assert_equal(",,Manager",       textized_row[3])
            assert_equal(",,Manager",       textized_row[4])
            assert_equal(",VP Production,", textized_row[5])
            assert_equal(",,Manager",       textized_row[6])
            assert_equal(",,Manager",       textized_row[7])
            assert_equal(",VP Sales,",      textized_row[8])
            assert_equal(",,Manager",       textized_row[9])
            assert_equal(",,Manager",       textized_row[10])
          end
        end
      end
      assert(has_xl_worksheets_sheet1_xml)

    ensure
      fin.close!
      fout.close!
    end

  end

  def test_main_list
    [%w[--list-type], %w[-l]].each do |args|
      out, err = capture_io do
        assert_exit_with(0) do
          HTOTConv::CLI.main(args)
        end
      end
      assert_match(HTOTConv::Parser.types.join(" "), out)
      assert_match(HTOTConv::Generator.types.join(" "), out)
      assert_equal("", err)
    end
  end

  def test_main_help
    [%w[--help], %w[-h], %w[-?]].each do |args|
      out, err = capture_io do
        assert_exit_with(0) do
          HTOTConv::CLI.main(args)
        end
      end

      assert_match(/Usage: htot_conv/, out)
      assert_equal("", err)
    end
  end

  def test_main_version
    out, err = capture_io do
      assert_exit_with(0) do
        HTOTConv::CLI.main(%w[--version])
      end
    end
    assert_equal("htot_conv #{HTOTConv::VERSION}\n", out)
    assert_equal("", err)
  end

  def test_main_wrong_argument
    out, err = capture_io do
      assert_exit_with(1) do
        HTOTConv::CLI.main(%w[--wrong-argument])
      end
    end
    assert_equal("invalid option: --wrong-argument\n", err)
  end
end
