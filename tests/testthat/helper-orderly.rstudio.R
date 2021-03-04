orderly_prepare_orderly_example <- orderly:::prepare_orderly_example

append_lines <- function(text, filename) {
  prev <- readLines(filename)
  writeLines(c(prev, text), filename)
}

skip_if_not_rstudio <- function(version = NULL) {
  available <- rstudioapi::isAvailable(version)
  message <- if (is.null(version))
    "RStudio not available"
  else
    paste("RStudio version '", version, "' not available", sep = "")

  if (!available)
    skip(message)

  TRUE
}
