#' Convert time format strings used in .its to numeric (seconds)
its_time_to_number <- function(x) {
  pattern <- "(?<=^P|PT)([0-9]+.[0-9]+)(?=S$)"
  as.numeric(stringr::str_extract(x, pattern))
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
