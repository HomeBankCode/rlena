#' Convert time format strings used in .its to numeric (seconds)
#' @param x An \code{.its} time string
#' @keywords internal
clean_time_str <- function(x) {
  pattern <- "(?<=^P|PT)([0-9]+.[0-9]+)(?=S$)"
  as.numeric(stringr::str_extract(x, pattern))
}



#' Convert timezone string used in \code{.its} to \code{lubridate} compatible
#' timezone name.
#'
#' The timezone format in the its files is not compatible with lubridate.
#' This function fixes this. See \code{OlsonNames()} for valid timezone names.
#' @param tz_str An \code{.its} timezone string
#' @keywords internal
clean_tz_str <- function(tz_str) {
  # Timezone strings have up to three parts, e.g. (GMT)(-08):(00)
  pattern <- "^([a-zA-Z/_-]*[^+-_]*)([+-][0-9]{0,2})?:?([03]{0,2})$"
  tz_parts <- stringr::str_match(tz_str, pattern)[2:3]

  if (is.na(tz_parts[2])) {
    tz_str # if no "+xy" info return tz_str unchanged
  } else {
    sprintf("Etc/%s%+i", tz_parts[1], as.numeric(tz_parts[2]))
  }
}



#' Extract timezone of the recording from \code{.its}
#' @param its_xml An \code{.its} xml tree
#' @keywords internal
extract_tz <- function(its_xml) {
  tz <- its_xml %>%
    xml2::xml_find_first(xpaths_bookmarks$timezoneinfo) %>%
    xml2::xml_attr("ZoneNameShort") %>%
    clean_tz_str()
}



add_its_filename <- function(df, its_xml) {
  tibble::add_column(
    df,
    its_File = extract_its_filename(its_xml),
    .before = 1)
}



extract_its_filename <- function(its_xml) {
  xml2::xml_attrs(its_xml)["fileName"]
}
