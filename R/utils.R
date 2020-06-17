get_colours <- function() {
  list(
    red = "#d9534f",
    blue = "#699ece",
    green = "#5cb85c",
    white = "#FFFFFF"
  )
}

list_reports <- function() {
  config <- orderly::orderly_config(NULL, locate = TRUE)
  paths <- orderly:::list_dirs(orderly:::path_src(config$root))
  meta <- file.info(paths)
  data.frame(report = basename(paths),
             path = paths,
             modified = meta$mtime,
             stringsAsFactors = FALSE)
}
