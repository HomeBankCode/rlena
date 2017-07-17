
#' Run multiple xpath attribute queries, collecting results in a dataframe
#' @param tree an xml document loaded by xml2
#' @param paths a vector of xpaths queries to run
#' @param labels an optional vector of category labels for each query
#' @return a data_frame object with the columns XPath and Value. If labels were
#'   supplied, an additional Category column is included.
#' @keywords internal
fetch_attr_paths <- function(tree, paths, labels = NULL) {
  # create a NULL label for each path if no labels given
  if (is.null(labels)) labels <- rep(list(NULL), length(paths))

  purrr::map2_df(paths, labels, ~ fetch_attr_path(tree, .x, .y))
}

#' Run xpath attribute query, storing results in a dataframe
#' @inheritParams fetch_attr_paths
#' @param path an xpath to an attribute value in a node
#' @param label an optional category label for the query
#' @return a data_frame object with the columns XPath and Value. If a label was
#'   supplied, an additional Category column is included.
#' @keywords internal
fetch_attr_path <- function(tree, path, label = NULL) {
  results <- tree %>%
    xml2::xml_find_all(path) %>%
    xml2::xml_text()

  df <- tibble::tibble(XPath = rep(path, length(results)), Value = results)

  if (!is.null(label)) {
    df <- df %>%
      dplyr::mutate(Category = label) %>%
      dplyr::select(Category, XPath, Value)
  }
  df
}
