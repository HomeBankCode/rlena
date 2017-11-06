# This script needs to b run only when the xpath paths that point to
# relevant parts of the .its are are changed or updated.
#
# The `paths.yaml` file contains "bookmarks" (xml paths) that point to
# relevant parts of the lena .its file.
# This script extracts these paths from paths.yaml as named lists
# (key - value pairs) and saves the lists as .rda files in data directory
# of the rlena package. The .rda files are loaded with the package, so
# that the bookmarks can be used by the package functions.

library("yaml")
library("dplyr")

xpaths <- yaml.load_file("data-raw/paths.yaml")
xpaths_bookmarks <- xpaths$bookmarks
xpaths_sensitive <- xpaths$sensitive %>%
  lapply(as_data_frame) %>%
  bind_rows()

devtools::use_data(xpaths_bookmarks, xpaths_sensitive, internal = T, overwrite = T)
