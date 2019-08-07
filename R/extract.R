#' Extract nodes of a certain type from an '.its' file as data frame.
#'
#' Most \code{gather_} functions extract all nodes of a certain type from a
#' \code{.its} file.
#' \describe{
#'   \item{gather_recordings}{all recording nodes}
#'   \item{gather_blocks}{all block nodes (pauses and conversations)}
#'   \item{gather_conversations}{all conversation nodes}
#'   \item{gather_pauses}{all pause nodes}
#'   \item{gather_segments}{all segment nodes}
#' }
#'
#' Other functions extract related nodes from the \code{.its}
#' \describe{
#'   \item{gather_ava_info}{Automatic Vocalization Assessment info}
#'   \item{gather_child_info}{child info}
#' }
#'
#' @param its_xml an .its file parsed with \code{\link{read_its_file}}
#' @return A data frame containing the extracted nodes.
#' @name extract
NULL




#' Return nodes of a certain type from an '.its' file as data frame.
#'
#' @inheritParams extract
#' @inheritParams xml_path_to_df
#' @param add_clock_time Logical. If TRUE (default) colums \code{startClockTime},
#' \code{endClockTime}, \code{startClockTimeLocal}, and \code{endClockTimeLocal}
#' will be added to the data frame. They contain timestams corresponding to the
#' \code{startTime}, and \code{endTime} columns.
#' @return A data frame containing the extracted nodes
#' @keywords internal
gather_path <- function(its_xml, path, add_clock_time = TRUE) {
  df <- its_xml %>%
    xml_path_to_df(path) %>%
    clean_time_cols() %>%
    add_its_id(its_xml)

  if (add_clock_time) {
    df <- add_clock_time(df, gather_recordings(its_xml))
  }

  sort_gathered_columns(df)
}



#' @rdname extract
#' @export
gather_recordings <- function(its_xml) {
  its_xml %>%
    gather_path(xpaths_bookmarks$recording, add_clock_time = FALSE) %>%
    dplyr::mutate(
      timeZone = extract_tz(its_xml),
      startClockTimeLocal = as_local_time(.data$startClockTime, .data$timeZone),
      endClockTimeLocal = as_local_time(.data$endClockTime, .data$timeZone)
    )
}



#' @rdname extract
#' @export
gather_blocks <- function(its_xml) {
  gather_path(its_xml, xpaths_bookmarks$block)
}




#' @rdname extract
#' @export
gather_conversations <- function(its_xml) {
  gather_path(its_xml, xpaths_bookmarks$conversation)
}




#' @rdname extract
#' @export
gather_pauses <- function(its_xml) {
    gather_path(its_xml, xpaths_bookmarks$pause)
}



#' @rdname extract
#' @export
gather_segments <- function(its_xml) {
  its_xml %>%
    gather_path(xpaths_bookmarks$segment) %>%
    split_conversation_info()
}



#' @rdname extract
#' @export
gather_ava_info <- function(its_xml) {
  its_xml %>%
    xml_path_to_df(xpaths_bookmarks$ava) %>%
    dplyr::select(
      AVA_Raw = .data$rawScore,
      AVA_Stnd = .data$standardScore,
      AVA_EstMLU = .data$estimatedMLU,
      AVA_EstDevAge = .data$estimatedDevAge) %>%
    add_its_id(its_xml)
}




#' @rdname extract
#' @export
gather_child_info <- function(its_xml) {
  results <- its_xml %>%
    xml_path_to_df(xpaths_bookmarks$childinfo) %>%
    add_col_if_missing(
      dob = NA_character_,
      gender = NA_character_,
      chronologicalAge = NA_character_,
      avaModelAge = NA_character_,
      vcvModelAge = NA_character_) %>%
    dplyr::rename(
      Birthdate = .data$dob,
      Gender = .data$gender,
      ChronologicalAge = .data$chronologicalAge,
      AVAModelAge = .data$avaModelAge,
      VCVModelAge = .data$vcvModelAge) %>%
    add_its_id(its_xml)

  # Back up location if birthday cannot be found
  if (is.na(results$Birthdate)) {
    other_dob <- its_xml %>%
      xml_path_to_df(xpaths_bookmarks$childinfo2) %>%
      add_col_if_missing(DOB = NA_character_)
    results$Birthdate <- other_dob$DOB
  }

  results
}


# for now treat as internal/experimental
#' Gather speaker transitions
#'
#' Combs throughs speech segments and returns a dataframe of speaker
#' transition.
#'
#' @param legal_transitions a character vector with transitions to keep. If
#'   `NULL` (the default), only `c("MAN_CHN", "MAN_CHN", "FAN_CHN", "CHN_FAN")`
#'   are used.
#' @inheritParams extract
#' @export
#' @keywords internal
#' @return a dataframe with one row per segment. It contains the columns
#'   `transSpkr` (speaker transition as `previous_current`,) `transSegId`
#'   (segment IDs), and `transTime` (the time lag between the two segments).
gather_speaker_transitions <- function(its_xml, legal_transitions = NULL) {
  its_xml %>%
    gather_segments() %>%
    gather_speaker_transitions_from_segments(legal_transitions)
}

# for now treat as internal/experimental
#' @param data_segments a dataframe produced by `gather_segments()`
#' @export
#' @keywords internal
#' @rdname gather_speaker_transitions
gather_speaker_transitions_from_segments <- function(data_segments,
                                                     legal_transitions = NULL) {
  if (is.null(legal_transitions)) {
    legal_transitions <- c(
      "MAN_CHN", "MAN_CHN",
      "FAN_CHN", "CHN_FAN"
    )
  }

  segments <- data_segments %>%
    tidyr::gather(
      key = "startEnd",
      value = "time",
      .data$startTime,
      .data$endTime
    ) %>%
    dplyr::arrange(.data$segId)

  no_pauses <- segments %>%
    dplyr::filter(.data$blkType != "Pause")

  # Label different kinds of transitions
  transitions <- no_pauses %>%
    dplyr::filter(.data$spkr != "SIL") %>%
    dplyr::mutate(
      transStartEnd =
        paste0(dplyr::lag(.data$startEnd, 1), "_", .data$startEnd),
      transSpkr =
        paste0(dplyr::lag(.data$spkr, 1), "_", .data$spkr),
      transTime =
        .data$time - dplyr::lag(.data$time),
      transSegId =
        paste0(dplyr::lag(.data$segId, 1), "_", .data$segId)
    )

  to_select <- c(
    "spkr", "startEnd", "time", "segId", "convTurnCount", "blkId",
    "transSpkr", "transSegId", "transTime"
  )

  transitions %>%
    # exclude within-turn transitions
    dplyr::filter(.data$transStartEnd != "startTime_endTime") %>%
    dplyr::filter(transSpkr %in% c(legal_transitions)) %>%
    dplyr::select(dplyr::one_of(to_select)) %>%
    tidyr::spread(.data$startEnd, .data$time)
}
