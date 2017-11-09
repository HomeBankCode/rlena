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
