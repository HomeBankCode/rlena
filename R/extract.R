#' @export
#' @import dplyr xml2
#' @importFrom readr type_convert
make_conversation_df <- function(lena_log) {
  # Extract attributes from the conversation nodes
  convos <- lena_log %>%
    xml_find_all("//ProcessingUnit/Recording/Conversation") %>%
    xml_attrs

  # xml_attrs returns named vectors. Convert to lists then bind to data_frame.
  convos_table <- convos %>%
    lapply(function(x) structure(as.list(x), names = names(x))) %>%
    lapply(as_data_frame) %>%
    bind_rows %>%
    type_convert %>%
    mutate(startTime = convert_time_to_number(startTime),
           endTime = convert_time_to_number(endTime))
  convos_table
}



#' @importFrom stringr str_replace
convert_time_to_number <- function(xs) {
  xs %>%
    str_replace("PT", "") %>%
    str_replace("S", "") %>%
    as.numeric
}
