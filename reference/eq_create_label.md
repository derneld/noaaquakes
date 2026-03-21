# Create HTML Labels for Earthquake Map

Create HTML Labels for Earthquake Map

## Usage

``` r
eq_create_label(data)
```

## Arguments

- data:

  A data frame containing LOCATION_NAME, EQ_PRIMARY, and DEATHS columns.

## Value

A character vector of HTML labels.

## Examples

``` r
if (FALSE) { # \dontrun{
data <- data.frame(LOCATION_NAME = "Tokyo", EQ_PRIMARY = 9.0, DEATHS = 15000)
eq_create_label(data)
} # }
```
