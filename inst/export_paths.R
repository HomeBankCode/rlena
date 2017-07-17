# Extract paths from yaml masterlist and import into R package

library("yaml")
library("dplyr")
library("magrittr")

xpaths_sensitive <- yaml.load_file("inst/paths.yaml") %>%
  extract2("sensitive") %>%
  lapply(as_data_frame) %>%
  bind_rows()

xpaths_bookmarks <- yaml.load_file("inst/paths.yaml") %>%
  extract2("bookmarks")

devtools::use_data(xpaths_sensitive, internal = FALSE, overwrite = TRUE)
devtools::use_data(xpaths_bookmarks, internal = FALSE, overwrite = TRUE)
