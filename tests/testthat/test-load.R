
context("load")

test_that("ITS files load", {
  xml_doc <- load_its_file("data/file-for-testing.its")
  doc_name <- xml2::xml_name(xml_doc)

  expect_equal(doc_name, "ITS")
})

