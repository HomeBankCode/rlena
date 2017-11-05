library("rlena")
context("read")


test_that("ITS file can be loaded", {
  f <- system.file("extdata", "example.its", package = "rlena")
  xml_doc <- read_its_file(f)
  doc_name <- xml2::xml_name(xml_doc)
  expect_equal(doc_name, "ITS")
})


test_that("All extractor funcitons return data frames", {
  f <- system.file("extdata", "example.its", package = "rlena")
  its <- read_its_file(f)
  expect_s3_class(gather_ava_info(its), "data.frame")
  expect_s3_class(gather_child_info(its), "data.frame")
  expect_s3_class(gather_conversations(its), "data.frame")
  expect_s3_class(gather_pauses(its), "data.frame")
})
