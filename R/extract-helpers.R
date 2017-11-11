#' Convert \code{.its} time format strings to numeric (seconds)
#' @param x An \code{.its} time string
#' @keywords internal
clean_time_str <- function(x) {
  pattern <- "(?<=^P|PT)([0-9]+.[0-9]+)(?=S$)"
  as.numeric(stringr::str_extract(x, pattern))
}



# Coerce all columns with LENA time strings to numeric (seconds)
clean_time_cols <- function(df) {
  pattern = paste(
    "(^(maleAdult|femaleAdult|child)(Utt|NonSpeech|CryVfx)(Len)$)",
    "(^(TV|CH|FA|CX|MA|NO|OL|NO|SIL)[N|F]{0,1}$)",
    "(^(start|end)(Time|Vfx1)$)",
    sep = "|")
  dplyr::mutate_at(df, dplyr::vars(dplyr::matches(pattern)), clean_time_str)
}



#' Make \code{.its} timezone string \code{lubridate} compatible
#'
#' The GMT timezone string in the \code{.its} files is not compatible with
#' lubridate. This function fixes it. See \code{OlsonNames()} for valid
#' timezone names.
#' @param tz_str An \code{.its} timezone string
#' @keywords internal
clean_tz_str <- function(tz_str) {
  # Timezone strings have up to three parts, e.g. (GMT)(-08):(00)
  pattern <- "^([a-zA-Z/_-]*[^+-_]*)([+-][0-9]{0,2})?:?([03]{0,2})$"
  tz_parts <- stringr::str_match(tz_str, pattern)[2:3]

  if (is.na(tz_parts[2])) {
    tz_str # if no "+hh:mm" info return tz_str unchanged
  } else {
    tz <- sub("Etc/", "", tz_parts[1])
    sprintf("Etc/%s%+i", tz, as.numeric(tz_parts[2]))
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



#' Use UTC time and timezone from \code{.its} file to calculate local time.
#'
#' In .its files all timestamps are stores in UTC time the actual timezone is
#' stored separately. This function converts the timestamps back to loccal time.
#' Local times are stored with timezone UTC, regardless of the actual timezone.
#' This is done for two resons: (1) So that "time of the day" can be compared
#' across LENA recordings made in different timezones, without converting to a
#' common time zone first. (2) Because time objects with
#' different timezones cannot be stored in the same column of a data frame.
#' @param utc_time A vector of POSIXct object to convert to local time
#' @param local_tzs A single local timezone to convert to or a vector of local
#' timezones with the same length as \code{utc_time}
#' @keywords internal
as_local_time <- function(utc_time, local_tzs) {
  lubridate::force_tzs(utc_time, local_tzs, tzone_out = "UTC")
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
