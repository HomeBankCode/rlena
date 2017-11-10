#' Read a LENA .its file
#' @param path A path to a LENA .its file
#' @export
read_its_file <- function(path) {
  xml2::read_xml(path) %>%
    add_id_attrs()
}



#' Add recording id, block id, and segment id to all annotation nodes
add_id_attrs <- function(its_xml) {
  recordings <- xml2::xml_find_all(its_xml, xpaths_bookmarks$recording)
  for (r in seq_along(recordings)) {
    xml2::xml_set_attr(recordings[r], "recId", r)

    blocks <- xml2::xml_children(recordings[r])
    for (b in seq_along(blocks)) {
      xml2::xml_set_attr(blocks[b], "recId", r)
      xml2::xml_set_attr(blocks[b], "blkId", b)

      segments <- xml2::xml_children(blocks[b])
      for (s in seq_along(segments)) {
        xml2::xml_set_attr(segments[s], "recId", r)
        xml2::xml_set_attr(segments[s], "blkId", b)
        xml2::xml_set_attr(segments[s], "segId", s)
      }
    }
  }
  its_xml
}
