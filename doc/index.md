# Types of input

## `simple_text`

 * A text file consisting of multiple lines where:
   * `<line> ::= { <indent> } <key> { <delimiter> <value> }`
   * `<key>` : a text that does not start with `<indent>` and does not contain `<delimiter>` (if `<delimiter>` specified).
   * `<value>` : a text that does not contain `<delimiter>`.
   * `<indent>` : specified by `--from-indent` option
   * `<delimiter>` : specified by `--from-delimiter` option

## `dir_tree`

 * Directory tree with the glob pattern specified by `--from-glob-pattern` (default: `**/*`)

## `html_list`

 * HTML `<ul><li>` and/or `<ol><li>` [nesting list](https://www.w3.org/wiki/HTML_lists#Nesting_lists).
 * All text outside of `<li>` elements is ignored.

## `opml`

 * [OPML](http://dev.opml.org/)
 * Treat the `text` attribute as a key text, the other attributes as values.

# Types of output

The sample input used in this section are as follows:

    1,1(1),1(2)
      1.1,1.1(1),1.1(2)
      1.2,1.2(1),1.2(2)
        1.2.1,1.2.1(1),1.2.1(2)

 * key header: H1, H2, H3
 * value header: H(1), H(2)

## `xlsx_type0`

| H1    | Level | H(1)     | H(2)     | 
|-------|-------|----------|----------| 
| 1     | 1     | 1(1)     | 1(2)     | 
| 1.1   | 2     | 1.1(1)   | 1.1(2)   | 
| 1.2   | 2     | 1.2(1)   | 1.2(2)   | 
| 1.2.1 | 3     | 1.2.1(1) | 1.2.1(2) | 

## `xlsx_type1`

| H1    | H(1)     | H(2)     | 
|-------|----------|----------| 
| 1     | 1(1)     | 1(2)     | 
| 1.1   | 1.1(1)   | 1.1(2)   | 
| 1.2   | 1.2(1)   | 1.2(2)   | 
| 1.2.1 | 1.2.1(1) | 1.2.1(2) | 

Not implemented (TODO):

 * Fill with different background color for each level.

## `xlsx_type2`

| H1 | H2  | H3    | H(1)     | H(2)     | 
|----|-----|-------|----------|----------| 
| 1  |     |       | 1(1)     | 1(2)     | 
|    | 1.1 |       | 1.1(1)   | 1.1(2)   | 
|    | 1.2 |       | 1.2(1)   | 1.2(2)   | 
|    |     | 1.2.1 | 1.2.1(1) | 1.2.1(2) | 

## `xlsx_type3`

| H1 | H(1) |        |          | H(2)     | 
|----|------|--------|----------|----------| 
| 1  | 1(1) |        |          | 1(2)     | 
|    | 1.1  | 1.1(1) |          | 1.1(2)   | 
|    | 1.2  | 1.2(1) |          | 1.2(2)   | 
|    |      | 1.2.1  | 1.2.1(1) | 1.2.1(2) | 

TODO: Github Flavored Markdown does not support the column span.
So, this document does not correctly represent type-3 xlsx spread sheet.

## `xlsx_type4`

| H1 | H2  | H3    | H(1)     | H(2)     | 
|----|-----|-------|----------|----------| 
| 1  | 1.1 |       | 1.1(1)   | 1.1(2)   | 
|    | 1.2 | 1.2.1 | 1.2.1(1) | 1.2.1(2) | 

## `xlsx_type5`

| H1 | H2  | H3    | H(1)     | H(2)     | 
|----|-----|-------|----------|----------| 
| 1  | 1.1 |       | 1.1(1)   | 1.1(2)   | 
| 1  | 1.2 | 1.2.1 | 1.2.1(1) | 1.2.1(2) | 

