library("rlena")
context("read")


test_that("All extractor functions return data frames", {
  f <- "../test.its"
  its <- read_its_file(f)
  expect_s3_class(gather_ava_info(its), "data.frame")
  expect_s3_class(gather_child_info(its), "data.frame")
  expect_s3_class(gather_recordings(its), "data.frame")
  expect_s3_class(gather_blocks(its), "data.frame")
  expect_s3_class(gather_conversations(its), "data.frame")
  expect_s3_class(gather_pauses(its), "data.frame")
  expect_s3_class(gather_segments(its), "data.frame")
})
