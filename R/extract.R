#' @export
gather_conversations <- function(lena_log) {
  # Extract attributes from the conversation nodes
  lena_log %>%
    xml_path_to_df(xpaths_bookmarks$conversation) %>%
    dplyr::mutate_(startTime = ~ convert_time_to_number(startTime),
                   endTime = ~ convert_time_to_number(endTime)) %>%
    add_its_filename(lena_log)
}



#' @export
gather_pauses <- function(lena_log) {
  lena_log %>%
    xml_path_to_df("./ProcessingUnit/Recording/Pause") %>%
    dplyr::mutate_(startTime = ~ convert_time_to_number(startTime),
                   endTime = ~ convert_time_to_number(endTime)) %>%
    add_its_filename(lena_log)
}


#' @export
gather_ava_info <- function(lena_log) {
  # Extract attributes from the conversation nodes
  lena_log %>%
    xml_path_to_df(xpaths_bookmarks$ava) %>%
    dplyr::select_(
      AVA_Raw = ~ rawScore,
      AVA_Stnd = ~ standardScore,
      AVA_EstMLU = ~ estimatedMLU,
      AVA_EstDevAge = ~ estimatedDevAge) %>%
    add_its_filename(lena_log)
}



#' @export
gather_child_info <- function(lena_log) {
  lena_log %>%
    xml_path_to_df(xpaths_bookmarks$childinfo) %>%
    dplyr::select_(
      Birthdate = ~ dob,
      Gender = ~ gender,
      ChronologicalAge = ~ chronologicalAge,
      AVAModelAge = ~ avaModelAge,
      VCVModelAge = ~ vcvModelAge) %>%
    add_its_filename(lena_log)
}



convert_time_to_number <- function(xs) {
  xs %>%
    stringr::str_replace("PT", "") %>%
    stringr::str_replace("S", "") %>%
    as.numeric()
}



add_its_filename <- function(df, lena_log) {
  tibble::add_column(
    df,
    ITSFile = extract_its_filename(lena_log),
    .before = 1)

}


extract_its_filename <- function(lena_log) {
  xml2::xml_attrs(lena_log)["fileName"]
}
