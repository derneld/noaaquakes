#' Read and Filter NOAA Earthquake Data
#'
#' @param file_path A character string pointing to the .tsv file.
#' @return A tibble with the raw data, skipping the search parameter header.
#' @importFrom readr read_tsv
#' @importFrom dplyr filter row_number
#' @export
eq_read_data <- function(file_path) {
  readr::read_tsv(file_path, skip = 0) %>%
    dplyr::filter(dplyr::row_number() != 1)
}

#' Clean Location Name column
#' @param x A character vector of location names
#' @return A cleaned character vector in title case without country prefixes
#' @export
#' @examples
#' eq_location_clean("JORDAN: BAB-A-DARAA")
#' eq_location_clean(c("USA: CALIFORNIA", "MEXICO: MEXICO CITY"))
eq_location_clean <- function(x) {
  x_clean <- stringr::str_remove(x, "^.*:\\s*")
  x_clean <- trimws(x_clean)
  x_clean <- stringr::str_to_title(x_clean)
  return(x_clean)
}

#' Standardize USA State Names
#' @param country_vec A character vector of country or state names
#' @return A character vector where state names are replaced with "USA"
#' @export
#' @examples
#' clean_usa_names(c("Mexico", "California", "France", "Texas"))
clean_usa_names <- function(country_vec) {
  is_state <- country_vec %in% datasets::state.name
  country_vec[is_state] <- "USA"
  return(country_vec)
}

#' Clean Earthquake Data
#'
#' Processes raw NOAA data into a tidy format suitable for visualization.
#'
#' @param df A data frame containing raw NOAA earthquake data.
#' @return A cleaned data frame with converted types, a Date column,
#' and separated Location/State columns.
#' @importFrom dplyr mutate select filter across
#' @importFrom lubridate make_date
#' @importFrom tidyr replace_na
#' @importFrom stringr str_to_title str_remove
#' @export
eq_clean_data <- function(df) {
  df %>%
    dplyr::select(-`Search Parameters`) %>%
    dplyr::filter(!is.na(Mag)) %>%
    dplyr::mutate(dplyr::across(c(Year, Mo, Dy, Hr, Mn, Sec, Latitude, Longitude,
                                  `Focal Depth (km)`, Mag, `MMI Int`, Deaths, Injuries),
                                as.numeric)) %>%
    dplyr::mutate(
      DATE = lubridate::make_date(Year, ifelse(is.na(Mo), 1, Mo), ifelse(is.na(Dy), 1, Dy)),
      # Extract the local region name
      LOCATION_NAME = eq_location_clean(`Location Name`),
      # Extract the prefix (Country or US State)
      ORIGINAL_PREFIX = stringr::str_to_title(stringr::str_remove(`Location Name`, ":\\s*.*$")),
      # Preservation of US State name
      US_STATE = ifelse(ORIGINAL_PREFIX %in% state.name, ORIGINAL_PREFIX, NA_character_),
      # Standardized Country/State column
      COUNTRY = ifelse(ORIGINAL_PREFIX %in% state.name, "USA", ORIGINAL_PREFIX),
      # Clean up numeric NAs
      DEATHS = tidyr::replace_na(Deaths, 0),
      INJURIES = tidyr::replace_na(Injuries, 0),
      EQ_PRIMARY = Mag
    ) %>%
    dplyr::select(-ORIGINAL_PREFIX, -Deaths, -Injuries, -Mag)
}
