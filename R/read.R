#' Read a LENA .its file
#' @param path A path to a LENA .its file
#' @export
read_its_file <- function(path) xml2::read_xml(path)
