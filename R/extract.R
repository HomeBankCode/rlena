#' Extract all conversation nodes as data frame.
#' @param its_xml the xml tree of an .its file
#' @export
gather_conversations <- function(its_xml) {
  # Extract attributes from the conversation nodes
  its_xml %>%
    xml_path_to_df(xpaths_bookmarks$conversation) %>%
    dplyr::mutate(startTime = convert_time_to_number(.data$startTime),
                  endTime = convert_time_to_number(.data$endTime)) %>%
    add_its_filename(its_xml)
}



#' Extract all pause nodes as data frame.
#' @param its_xml the xml tree of an .its file
#' @export
gather_pauses <- function(its_xml) {
  its_xml %>%
    xml_path_to_df(xpaths_bookmarks$pause) %>%
    dplyr::mutate(startTime = convert_time_to_number(.data$startTime),
                  endTime = convert_time_to_number(.data$endTime)) %>%
    add_its_filename(its_xml)
}



#' Extract Automatic Vocalization Assessment info as data frame.
#' @param its_xml the xml tree of an .its file
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



#' Extract all child info as data frame.
#' @param its_xml the xml tree of an .its file
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



convert_time_to_number <- function(xs) {
  xs %>%
    stringr::str_replace("PT", "") %>%
    stringr::str_replace("S", "") %>%
    as.numeric()
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
