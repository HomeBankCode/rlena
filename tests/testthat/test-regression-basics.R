# Regression checks for the bundled LENA ITS fixture.
# These tests exercise existing behavior; no parser algorithms are changed.

test_that("ITS file metadata is preserved", {
  its <- read_its_file("../test.its")

  expect_equal(xml2::xml_name(its), "ITS")
  expect_equal(xml2::xml_attr(its, "fileName"),
               "20171107_114301_022867")
})

test_that("recording IDs are assigned in file order", {
  its <- read_its_file("../test.its")

  recordings <- xml2::xml_find_all(
    its,
    "//ProcessingUnit/Recording"
  )

  ids <- as.integer(
    xml2::xml_attr(recordings, "recId")
  )

  expect_gt(length(recordings), 0L)
  expect_false(anyNA(ids))
  expect_equal(ids, seq_along(recordings))
})

test_that("block IDs are consecutive across recordings", {
  its <- read_its_file("../test.its")
  blocks <- xml2::xml_find_all(its, ".//Recording/*")

  expect_gt(length(blocks), 0L)
  ids <- as.integer(xml2::xml_attr(blocks, "blkId"))
  expect_equal(ids, seq_along(blocks))
})

test_that("segment IDs are consecutive across blocks", {
  its <- read_its_file("../test.its")
  segments <- xml2::xml_find_all(its, ".//Segment")

  expect_gt(length(segments), 0L)
  ids <- as.integer(xml2::xml_attr(segments, "segId"))
  expect_equal(ids, seq_along(segments))
})

test_that("recording duration is converted to seconds", {
  its <- read_its_file("../test.its")
  recordings <- gather_recordings(its)

  expect_equal(recordings$startTime[[1L]], 0)
  expect_equal(recordings$endTime[[1L]], 313.85,
               tolerance = 1e-7)
})
