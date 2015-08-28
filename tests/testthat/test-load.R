
context("load")

library("xml2")

test_that("ITS files load", {
  xml_doc <- load_its_file("data/file-for-testing.its")
  doc_name <- xml_name(xml_doc)

  expect_equal(doc_name, "ITS")
})
