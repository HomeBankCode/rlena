library("rlena")
context("read")


test_that("ITS file can be loaded", {
  f <- system.file("extdata", "example.its", package = "rlena")
  xml_doc <- read_its_file(f)
  doc_name <- xml2::xml_name(xml_doc)

  expect_equal(doc_name, "ITS")
})
