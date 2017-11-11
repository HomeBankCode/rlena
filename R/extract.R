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
#'   \item{#gather_ava_info}{Automatic Vocalization Assessment info}
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

  if (add_clock_time)
    df <- add_clock_time(df, gather_recordings(its_xml))

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
  its_xml %>%
    xml_path_to_df(xpaths_bookmarks$childinfo) %>%
    dplyr::select(
      Birthdate = .data$dob,
      Gender = .data$gender,
      ChronologicalAge = .data$chronologicalAge,
      AVAModelAge = .data$avaModelAge,
      VCVModelAge = .data$vcvModelAge) %>%
    add_its_id(its_xml)
}
