get_colours <- function() {
  list(
    red = "#d9534f",
    blue = "#699ece",
    green = "#5cb85c",
    white = "#FFFFFF"
  )
}

system_file <- function(...) {
  system.file(..., package = "orderly.rstudio", mustWork = TRUE)
}
