# Interactive Earthquake Map

Interactive Earthquake Map

## Usage

``` r
eq_map(data, annot_col = "DATE")
```

## Arguments

- data:

  A filtered data frame containing earthquake data.

- annot_col:

  A character string specifying the column name to use for pop-up
  annotations.

## Value

A leaflet object displaying the map.

## Examples

``` r
if (FALSE) { # \dontrun{
eq_map(sample_data, annot_col = "DATE")
} # }
```
