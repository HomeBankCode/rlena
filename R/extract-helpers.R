#' Add default-value columns to a dataframe
#'
#' @param df a dataframe
#' @param ... key-value pairs. The lefthand side should be the name of the
#'   desired column and the righthand should be the value to use as a default.
#' @return the dataframe is returned. If any of columns named in \code{...} are
#'   missing, they are added to the dataframe.
#' @keywords internal
#' @examples
#' \dontrun{
#' add_col_if_missing(
#'   iris,
#'   Species = "col exists. this shouldn't do anything",
#'   Species2 = "col doesn't exist. this should be added")
#' }
add_col_if_missing <- function(df, ...) {
  to_check <- list(...)
  for (element in seq_along(to_check)) {
    if (!rlang::has_name(df, names(to_check)[element])) {
      df <- tibble::add_column(df, !!! to_check[element])
    }
  }

  df
}


#' Convert \code{.its} time format strings to numeric (seconds)
#'
#' @param x An \code{.its} time string
#' @return A numeric (time in seconds)
#' @keywords internal
clean_time_str <- function(x) {
  pattern <- "(?<=^P|PT)([0-9]+.[0-9]+)(?=S$)"
  as.numeric(stringr::str_extract(x, pattern))
}



#' Coerce all columns with LENA time strings to numeric (seconds)
#'
#' @param df A data frame produced by any of the \code{gather_} functions.
#' @return A data frame with all time columns converted to numeric
#' @keywords internal
clean_time_cols <- function(df) {
  pattern <- paste(
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
#'
#' @param tz_str An \code{.its} timezone string
#' @return A lubridate compatible timezon character string
#' @keywords internal
clean_tz_str <- function(tz_str) {
  # Timezone strings have up to three parts, e.g. (GMT)(-08):(00)
  pattern <- "^([a-zA-Z/_-]*[^+-_]*)([+-][0-9]{0,2})?:?([03]{0,2})$"
  tz_parts <- stringr::str_match(tz_str, pattern)[2:3]

  if (is.na(tz_parts[2])) {
    # if no "+hh:mm" info return tz_str unchanged
    tz_str
  } else {
    tz <- sub("Etc/", "", tz_parts[1])
    sprintf("Etc/%s%+i", tz, as.numeric(tz_parts[2]))
  }
}



#' Extract timezone of the recording from \code{.its}
#'
#' @param its_xml An \code{.its} xml tree
#' @return A character string, the name of the timezone used in the \code{.its}
#' @keywords internal
extract_tz <- function(its_xml) {
  its_xml %>%
    xml2::xml_find_first(xpaths_bookmarks$timezoneinfo) %>%
    xml2::xml_attr("ZoneNameShort") %>%
    clean_tz_str()
}



#' Use UTC time and timezone from \code{.its} file to calculate local time.
#'
#' In .its files all timestamps are stores in UTC time the actual timezone is
#' stored separately. This function converts the timestamps back to local time.
#' Local times are stored with timezone UTC, regardless of the actual timezone.
#' This is done for two resons: (1) So that "time of the day" can be compared
#' across LENA recordings made in different timezones, without converting to a
#' common time zone first. (2) Because time objects with
#' different timezones cannot be stored in the same column of a data frame.
#'
#' @param utc_time A vector of POSIXct object to convert to local time
#' @param local_tzs A single local timezone to convert to or a vector of local
#' timezones with the same length as \code{utc_time}
#' @keywords internal
as_local_time <- function(utc_time, local_tzs) {
  # do nothing if no timezone could be found
  local_tzs <- ifelse(is.na(local_tzs), "UTC", local_tzs)
  lubridate::force_tzs(utc_time, local_tzs, tzone_out = "UTC")
}



#' Split conversationInfo column
#'
#' Some segment nodes contain a \code{conversationInfo} attribute with
#' additional information related to vocalization activity blocks and turns.
#' This function parses this information into separate columns.
#'
#' @param segment_df A data frame produced by \code{gather_segments()}
#' @return A data frame with additional columns with conversation information
#' @keywords internal
split_conversation_info <- function(segments_df) {
  segments_df %>%
    dplyr::mutate(
      conversationInfo =
        substr(
          x = .data$conversationInfo,
          start = 2,
          stop = nchar(.data$conversationInfo) - 1)) %>%
    tidyr::separate(
      .data$conversationInfo,
      into = c(
        "convStatus",        # (BC) begin, (RC) running, (EC) end of block
        "convCount",         # Running Block Count for entire '.its' file
        "convTurnCount",     # Running Turn Count for recording
        "convResponseCount", # Turn count within block
        "convType",          # codes for initiator and participants
        "convTurnType",      # turn type (TIFI/TIMI/TIFR/TIMR/TIFE/TIME/NT)
        "convFloorType"),      # (FI) : Floor Initiation, (FH) : Floor Holding
      sep = "\\|",
      remove = FALSE,
      convert = TRUE)
}



#' Add \code{.its} filename to a data frame produced by any of the
#' \code{gather_} functions
#'
#' @param df A data frame produced by one of the \code{gather_} functions
#' @param its_xml The \code{.its} xml tree corresponding to the data frame
#' @return A data frame eith an additional column \code{its_file}, containing
#' the name of the corresponding \code{.its} file
#' @keywords internal
add_its_id <- function(df, its_xml) {
  tibble::add_column(df, itsId = extract_its_filename(its_xml), .before = 1)
}



#' Extract its filename from the \code{.its} xml tree
#'
#' @param its_xml An \code{.its} xml tree
#' @return A character string, the name of the \code{.its} file as found in
#' the \code{.its} xml tree
#' @keywords internal
extract_its_filename <- function(its_xml) {
  as.character(xml2::xml_attrs(its_xml)["fileName"])
}



#' Add clock times to a data frame of nodes
#'
#' The segment and block nodes only have startTime and endTime attributes that
#' indicate the time since the beginning of the corresponding recording (in
#' seconds). This function takes a data frame with recording information and
#' adds the corresponding clock time (UTC) and local time (adjusted for
#' timezone). Note that the local time is correctly adjusted but still stored
#' with timezone "UTC". See \code{\link{as_local_time}} for more information.
#'
#' @param df A data frame created by one of the \code{gather} functions. Must
#' contain a \code{startTime} and \code{endTime} column that contain the seconds
#' since the start of the recording.
#' @return A data frame with \code{startClockTime}, \code{endClockTime},
#' \code{startClockTimeLocal}, and \code{endClockTimeLocal} columns for each
#' recording.
#' @keywords internal
add_clock_time <- function(df, df_rec) {
  rec_start_times <- df_rec %>%
    dplyr::select(
      recId = .data$recId,
      startTime_rec = .data$startTime,
      startClockTime_rec = .data$startClockTime,
      startClockTimeLocal_rec = .data$startClockTimeLocal)

  df_clock_times <- df %>%
    dplyr::select(.data$recId, .data$startTime, .data$endTime) %>%
    dplyr::left_join(rec_start_times, by = "recId") %>%
    dplyr::mutate(
      startTime_diff = lubridate::seconds(
        .data$startTime - .data$startTime_rec),
      endTime_diff = lubridate::seconds(
        .data$endTime - .data$startTime_rec)) %>%
    dplyr::transmute(
      startClockTime = .data$startClockTime_rec + .data$startTime_diff,
      endClockTime = .data$startClockTime_rec + .data$endTime_diff,
      startClockTimeLocal = .data$startClockTimeLocal_rec +
        .data$startTime_diff,
      endClockTimeLocal = .data$startClockTimeLocal_rec + .data$endTime_diff)

  df <- dplyr::bind_cols(df, df_clock_times)
}


#' Sort columns in data frames produced by any of the \code{gather_} functions
#'
#' @param df A data frames produced by any of the \code{gather_} functions
#' @return The data frame with columns in a different order.
#' @keywords internal
sort_gathered_columns <- function(df) {
  # To avoid an "unknown columns" warning we filter the columns before we use
  # dplyr::select
  cols_ordered <- c(
    "itsId", "recId", "blkId", "blkTypeId", "segId", "blkType", "spkr",
    "startTime", "endTime", "startClockTime", "endClockTime",
    "startClockTimeLocal", "endClockTimeLocal")

  cols_in_df <- cols_ordered[cols_ordered %in% colnames(df)]
  dplyr::select(df, dplyr::one_of(cols_in_df), dplyr::everything())
}
