#' Read a LENA .its file
#'
#' Read a LENA .its file and prepare it for being used with other rlena
#' functions
#'
#' @param x A path to a LENA .its file or an its file that has been parsed
#' with \code{xml2::read_xml}
#' @return The parsed \code{.its} file as an \code{xml_document} object
#' @export
read_its_file <- function(x) {
  if (!inherits(x, "xml_document")) {
    x <- xml2::read_xml(x)
  }
  add_id_attrs(x)
}



#' Add recording id, block id, and segment id to all annotation nodes
#' These ids can later serve as foreign keys for join operations etc.
#' @keywords internal
add_id_attrs <- function(its_xml) {
  r <- 0
  b <- 0
  s <- 0
  recordings <- xml2::xml_find_all(its_xml, xpaths_bookmarks$recording)
  for (rec in recordings) {
    r <- r + 1
    xml2::xml_set_attr(rec, "num", NULL)
    xml2::xml_set_attr(rec, "recId", r)

    blocks <- xml2::xml_children(recordings[r])
    for (blk in blocks) {
      b <- b + 1
      blkTypeId <- xml2::xml_attr(blk, "num") # running count of Pauses / Conv.
      blkType <- xml2::xml_name(blk)
      xml2::xml_set_attr(blk, "recId", r)
      xml2::xml_set_attr(blk, "blkId", b)
      xml2::xml_set_attr(blk, "blkTypeId", blkTypeId)
      xml2::xml_set_attr(blk, "num", NULL)
      xml2::xml_set_attr(blk, "blkType", blkType)

      segments <- xml2::xml_children(blk)
      for (seg in segments) {
        s <- s + 1
        xml2::xml_set_attr(seg, "recId", r)
        xml2::xml_set_attr(seg, "blkId", b)
        xml2::xml_set_attr(seg, "blkTypeId", blkTypeId)
        xml2::xml_set_attr(seg, "segId", s)
        xml2::xml_set_attr(seg, "blkType", blkType)
      }
    }
  }
  its_xml
}
