library(testthat)
library(ggplot2)
library(dplyr)
library(lubridate)

# Create a small mockup dataset for testing
test_data <- tibble::tibble(
  Year = 2000, Mo = 5, Dy = 20,
  `Location Name` = "USA: CALIFORNIA",
  Mag = 6.5, Deaths = 10, Injuries = 5,
  Latitude = 34.0, Longitude = -118.0,
  `Search Parameters` = "none",
  `Focal Depth (km)` = 10, `MMI Int` = 7, Hr = 1, Mn = 1, Sec = 1
)

test_that("eq_clean_data handles missing months/days correctly", {
  # Create data with NA in Month/Day
  na_data <- test_data %>% mutate(Mo = NA, Dy = NA)
  cleaned <- eq_clean_data(na_data)

  # eq_clean_data uses make_date with ifelse for NAs
  expect_s3_class(cleaned$DATE, "Date")
  expect_equal(lubridate::month(cleaned$DATE), 1)
})

test_that("geom_timeline renders without error", {
  cleaned <- eq_clean_data(test_data)

  # Tests if the ggplot object can be built (checks the draw_panel logic)
  p <- ggplot(cleaned, aes(x = DATE, y = COUNTRY, size = EQ_PRIMARY, color = DEATHS)) +
    geom_timeline()

  expect_silent(ggplot_build(p))
})

test_that("geom_timeline_label handles top N earthquakes", {
  # Create multiple rows to test slice_max logic in StatTimelineLabel
  multi_data <- bind_rows(test_data, test_data %>% mutate(Mag = 8.0, `Location Name` = "USA: BIG ONE"))
  cleaned <- eq_clean_data(multi_data)

  p <- ggplot(cleaned, aes(x = DATE, y = COUNTRY, label = LOCATION_NAME, magnitude = EQ_PRIMARY)) +
    geom_timeline_label(n_max = 1)

  # Ensure the stat correctly filters to 1 row per group
  built <- ggplot_build(p)
  expect_equal(nrow(built$data[[1]]), 1)
})
