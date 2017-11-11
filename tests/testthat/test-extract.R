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
  f <- function(time, zone) lubridate::with_tz(time, clean_tz_str(zone))
  expect_s3_class(f(t, "Africa/Abidjan"), "POSIXct")
  expect_s3_class(f(t, "America/New_York"), "POSIXct")
  expect_s3_class(f(t, "America/Argentina/Catamarca"), "POSIXct")
  expect_s3_class(f(t, "America/North_Dakota/New_Salem"), "POSIXct")
  expect_s3_class(f(t, "CET"), "POSIXct")
  expect_s3_class(f(t, "CST6CDT"), "POSIXct")
  expect_s3_class(f(t, "Etc/GMT-1"), "POSIXct")
  expect_s3_class(f(t, "Etc/GMT-12"), "POSIXct")
  expect_s3_class(f(t, "Etc/GMT+0"), "POSIXct")
  expect_s3_class(f(t, "Etc/UCT"), "POSIXct")
  expect_s3_class(f(t, "GB"), "POSIXct")
  expect_s3_class(f(t, "US/Pacific-New"), "POSIXct")
  expect_s3_class(f(t, "W-SU"), "POSIXct")
  expect_s3_class(f(t, "GMT+01:00"), "POSIXct")
  expect_s3_class(f(t, "GMT-08:00"), "POSIXct")
  expect_s3_class(f(t, "GMT+01"), "POSIXct")
})


test_that("extract_tz returns timezone", {
  f <- "../test.its"
  its <- read_its_file(f)
  tz <- extract_tz(its)
  expect_type(tz, "character")
  expect_s3_class(lubridate::with_tz(lubridate::now(), tz), "POSIXct")
})


test_that("clean_time_cols finds and cleans all time cols", {
  f <- "../test.its"
  its <- read_its_file(f)
  blocks <- gather_blocks(its)

  expect_type(blocks$TVF, "double")
  expect_type(blocks$FAN, "double")
  expect_type(blocks$OLN, "double")
  expect_type(blocks$SIL, "double")
  expect_type(blocks$NOF, "double")
  expect_type(blocks$CXF, "double")
  expect_type(blocks$OLF, "double")
  expect_type(blocks$CHF, "double")
  expect_type(blocks$MAF, "double")
  expect_type(blocks$TVN, "double")
  expect_type(blocks$NON, "double")
  expect_type(blocks$CXN, "double")
  expect_type(blocks$CHN, "double")
  expect_type(blocks$MAN, "double")
  expect_type(blocks$FAF, "double")
  expect_type(blocks$femaleAdultNonSpeechLen, "double")
  expect_type(blocks$femaleAdultNonSpeechLen, "double")
  expect_type(blocks$maleAdultNonSpeechLen, "double")
  expect_type(blocks$maleAdultUttLen, "double")
  expect_type(blocks$femaleAdultUttLen, "double")
  expect_type(blocks$childUttLen, "double")
  expect_type(blocks$childCryVfxLen, "double")
  expect_type(blocks$startTime, "double")
  expect_type(blocks$endTime, "double")

  # test columns that don't appear in blocks
  segments <- gather_segments(its)
  expect_type(segments$startVfx1, "double")
  expect_type(segments$endVfx1, "double")
})
