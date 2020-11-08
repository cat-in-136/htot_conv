# HTOTConv - Hierarchical-Tree Outline Text Converter

Convert from a simple hierarchical-tree outline text into ugly xlsx file

[![Gem Version](https://badge.fury.io/rb/htot_conv.svg)](https://badge.fury.io/rb/htot_conv)
[![Ruby](https://github.com/cat-in-136/htot_conv/workflows/Ruby/badge.svg)](https://github.com/cat-in-136/htot_conv/actions)

## Installation

Install `htot_conv` via RubyGems. Simply run the following command to install:

    $ gem install htot_conv

## Usage

    $ cat outline.txt
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
    $ htot_conv -f simple_text --from-indent=. -t xlsx_type2 outline.txt outline.xlsx
    $ xdg-open outline.xlsx

See [docs/index.md](docs/index.md) for detail.

## Development

    $ bundle install --path=vendor/bundle --with development test
    $ bundle exec rake test

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/cat-in-136/htot_conv>.


## License

[MIT License](http://opensource.org/licenses/MIT).
See the `LICENSE.txt` file.

