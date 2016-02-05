# Find the depth of each node in a list
find_depth <- function(x, depth = 0) {
  if (is.list(x) & length(x) != 0) {
    depth <- map(x, find_depth, depth + 1)
  }
  depth
}

# Find deepest node
max_depth <- . %>%
  find_depth %>%
  unlist(use.names = FALSE) %>%
  max(na.rm = TRUE)

# apply a function at each depth of a list
descend <- function(.x, .f, ...) {
  .f <- as_function(.f)
  depth <- max_depth(.x)

  for(d in seq_len(depth)) {
    .x <- at_depth(.x, d, .f)
  }
  .x
}

promote_attributes <- function(x) {
  x <- as.list(x)
  if (".attrs" %in% names(x)) {
    attrs <- getElement(x, ".attrs")
    x$.attrs <- NULL
    x <- splice(as.list(attrs), x)
  }
  x
}
