#' Interactive Earthquake Map
#' @param data A filtered data frame containing earthquake data.
#' @param annot_col A character string specifying the column name to use for pop-up annotations.
#' @return A leaflet object displaying the map.
#' @importFrom leaflet leaflet addTiles addCircleMarkers
#' @export
#' @examples
#' \dontrun{
#' eq_map(sample_data, annot_col = "DATE")
#' }
eq_map <- function(data, annot_col = "DATE") {
  leaflet::leaflet(data) |>
    leaflet::addTiles() |>
    leaflet::addCircleMarkers(
      lng = ~Longitude,
      lat = ~Latitude,
      radius = ~EQ_PRIMARY,
      weight = 1,
      fillOpacity = 0.4,
      popup = ~get(annot_col)
    )
}

#' Create HTML Labels for Earthquake Map
#' @param data A data frame containing LOCATION_NAME, EQ_PRIMARY, and DEATHS columns.
#' @return A character vector of HTML labels.
#' @export
#' @examples
#' \dontrun{
#' data <- data.frame(LOCATION_NAME = "Tokyo", EQ_PRIMARY = 9.0, DEATHS = 15000)
#' eq_create_label(data)
#' }
eq_create_label <- function(data) {
  # Validate columns exist
  required_cols <- c("LOCATION_NAME", "EQ_PRIMARY", "DEATHS")
  if (!all(required_cols %in% names(data))) {
    stop("Input data must contain: LOCATION_NAME, EQ_PRIMARY, and DEATHS")
  }

  # Helper to build a single row of text if data exists
  build_line <- function(label, value) {
    ifelse(!is.na(value), paste0("<b>", label, ":</b> ", value, "<br/>"), "")
  }

  # Apply the helper across the specified columns
  apply(data, 1, function(row) {
    # Extract values (ensuring they are handled as the correct type)
    loc    <- build_line("Location", row["LOCATION_NAME"])
    mag    <- build_line("Magnitude", row["EQ_PRIMARY"])
    deaths <- build_line("Total deaths", row["DEATHS"])

    paste0(loc, mag, deaths)
  })
}
