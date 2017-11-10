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


test_that("clean_tz_str works with common timezone formats", {
  t <- lubridate::now()
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("Africa/Abidjan")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("America/New_York")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("America/Argentina/Catamarca")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("America/North_Dakota/New_Salem")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("CET")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("CST6CDT")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("Etc/GMT-1")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("Etc/GMT-12")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("Etc/GMT+0")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("Etc/UCT")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("GB")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("US/Pacific-New")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("W-SU")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("GMT+01:00")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("GMT-08:00")), "POSIXct")
  expect_s3_class(lubridate::with_tz(t, clean_tz_str("GMT+01")), "POSIXct")
})


test_that("extract_tz returns timezone", {
  f <- "../test.its"
  its <- read_its_file(f)
  tz <- extract_tz(its)
  expect_type(tz, "character")
  expect_s3_class(lubridate::with_tz(lubridate::now(), tz), "POSIXct")
})
