# HTOTConv - Hierarchical-Tree Outline Text Converter

Convert from a simple hierarchical-tree outline text into ugly xlsx file

[![Gem Version](https://badge.fury.io/rb/htot_conv.svg)](https://badge.fury.io/rb/htot_conv)
[![Build Status](https://travis-ci.org/cat-in-136/htot_conv.svg?branch=master)](https://travis-ci.org/cat-in-136/htot_conv)

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

### Types of input

#### `simple_text`

 * A text file consisting of multiple lines where:
   * `<line> ::= { <indent> } <key> { <delimiter> <value> }`
   * `<key>` : a text that does not start with `<indent>` and does not contain `<delimiter>` (if `<delimiter>` specified).
   * `<value>` : a text that does not contain `<delimiter>`.
   * `<indent>` : specified by `--from-indent` option
   * `<delimiter>` : specified by `--from-delimiter` option

#### `html_list`

 * HTML `<ul><li>` and/or `<ol><li>` [nesting list](https://www.w3.org/wiki/HTML_lists#Nesting_lists).
 * All text outside of `<li>` elements is ignored.

### Types of output

The sample input used in this section are as follows:

    1,1(1),1(2)
      1.1,1.1(1),1.1(2)
      1.2,1.2(1),1.2(2)
        1.2.1,1.2.1(1),1.2.1(2)

 * key header: H1, H2, H3
 * value header: H(1), H(2)

#### `xlsx_type0`

| H1    | Level | H(1)     | H(2)     | 
|-------|-------|----------|----------| 
| 1     | 1     | 1(1)     | 1(2)     | 
| 1.1   | 2     | 1.1(1)   | 1.1(2)   | 
| 1.2   | 2     | 1.2(1)   | 1.2(2)   | 
| 1.2.1 | 3     | 1.2.1(1) | 1.2.1(2) | 

#### `xlsx_type1`

| H1    | H(1)     | H(2)     | 
|-------|----------|----------| 
| 1     | 1(1)     | 1(2)     | 
| 1.1   | 1.1(1)   | 1.1(2)   | 
| 1.2   | 1.2(1)   | 1.2(2)   | 
| 1.2.1 | 1.2.1(1) | 1.2.1(2) | 

Not implemented (TODO):

 * Fill with different background color for each level.

#### `xlsx_type2`

| H1 | H2  | H3    | H(1)     | H(2)     | 
|----|-----|-------|----------|----------| 
| 1  |     |       | 1(1)     | 1(2)     | 
|    | 1.1 |       | 1.1(1)   | 1.1(2)   | 
|    | 1.2 |       | 1.2(1)   | 1.2(2)   | 
|    |     | 1.2.1 | 1.2.1(1) | 1.2.1(2) | 

Not implemented (TODO):

 * Cell integration over row.

#### `xlsx_type3`

Not supported (implemented) as of now.

| H1 | H(1) |        |          | H(2)     | 
|----|------|--------|----------|----------| 
| 1  | 1(1) |        |          | 1(2)     | 
|    | 1.1  | 1.1(1) |          | 1.1(2)   | 
|    | 1.2  | 1.2(1) |          | 1.2(2)   | 
|    |      | 1.2.1  | 1.2.1(1) | 1.2.1(2) | 

TODO: Github Flavored Markdown does not support for column span.
So, this document does not correctly represent type-3 xlsx spread sheet.

#### `xlsx_type4`

| H1 | H2  | H3    | H(1)     | H(2)     | 
|----|-----|-------|----------|----------| 
| 1  | 1.1 |       | 1.1(1)   | 1.1(2)   | 
|    | 1.2 | 1.2.1 | 1.2.1(1) | 1.2.1(2) | 

Not implemented (TODO):

 * Cell integration over column.

#### `xlsx_type5`

| H1 | H2  | H3    | H(1)     | H(2)     | 
|----|-----|-------|----------|----------| 
| 1  | 1.1 |       | 1.1(1)   | 1.1(2)   | 
| 1  | 1.2 | 1.2.1 | 1.2.1(1) | 1.2.1(2) | 

Not implemented (TODO):

 * Cell integration over column.

## Development

    $ bundle install --path=vendor/bundle --with development test
    $ bundle exec rake test

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/cat-in-136/htot_conv>.


## License

[MIT License](http://opensource.org/licenses/MIT).
See the `LICENSE.txt` file.

