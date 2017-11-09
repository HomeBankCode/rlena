#' Extract nodes of a certain type from an '.its' file as data frame.
#'
#' gather_recordings - Extract all recording nodes,  as data frame.
#' gather_blocks - Extract all block nodes (pauses and conversations) as data
#' frame.
#' gather_conversations - Extract all conversation nodes as data frame.
#' gather_pauses - Extract all pause nodes as data frame.
#' gather_segments - Extract all segment nodes as data frame.
#' #gather_ava_info - Extract Automatic Vocalization Assessment info as data
#' frame.
#' gather_child_info - Extract all child info as data frame.
#'
#' @param its_xml the xml tree of an .its file
#' @name extract
NULL



#' @rdname extract
#' @export
gather_recordings <- function(its_xml) {
  NULL
}




#' @rdname extract
#' @export
gather_blocks <- function(its_xml) {
  NULL
}




#' @rdname extract
#' @export
gather_conversations <- function(its_xml) {
  # Extract attributes from the conversation nodes
  its_xml %>%
    xml_path_to_df(xpaths_bookmarks$conversation) %>%
    dplyr::mutate(startTime = convert_time_to_number(.data$startTime),
                  endTime = convert_time_to_number(.data$endTime)) %>%
    add_its_filename(its_xml)
}




#' @rdname extract
#' @export
gather_pauses <- function(its_xml) {
  its_xml %>%
    xml_path_to_df(xpaths_bookmarks$pause) %>%
    dplyr::mutate(startTime = convert_time_to_number(.data$startTime),
                  endTime = convert_time_to_number(.data$endTime)) %>%
    add_its_filename(its_xml)
}



#' @rdname extract
#' @export
gather_segments <- function(its_xml) {
  NULL
}



#' @rdname extract
#' @export
gather_ava_info <- function(its_xml) {
  # Extract attributes from the conversation nodes
  its_xml %>%
    xml_path_to_df(xpaths_bookmarks$ava) %>%
    dplyr::select(
      AVA_Raw = .data$rawScore,
      AVA_Stnd = .data$standardScore,
      AVA_EstMLU = .data$estimatedMLU,
      AVA_EstDevAge = .data$estimatedDevAge) %>%
    add_its_filename(its_xml)
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
    add_its_filename(its_xml)
}
