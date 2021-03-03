## Setup orderly bin
write_script <- function(path, code, versioned = FALSE) {
  if (!isTRUE(file.info(path, extra_cols = FALSE)$isdir)) {
    stop("'path' must be a directory")
  }
  if (versioned) {
    rscript <- file.path(R.home(), "bin", "Rscript")
  } else {
    rscript <- "/usr/bin/env Rscript"
  }
  code <- c(sprintf("#!%s", rscript), code)
  path_bin <- file.path(path, "orderly.server")
  writeLines(code, path_bin)
  Sys.chmod(path_bin, "755")
  invisible(path_bin)
}

bin <- tempfile()
dir.create(bin)
orderly_bin <- write_script(
  bin,
  readLines(system.file("script", package = "orderly", mustWork = TRUE)),
  versioned = TRUE)

## Helpers
path_draft <- function(root) {
  file.path(root, "draft")
}

path_archive <- function(root) {
  file.path(root, "archive")
}

readlines_if_exists <- function(path, missing = NULL) {
  if (file.exists(path)) {
    readLines(path)
  } else {
    missing
  }
}

file_copy <- function(..., overwrite = TRUE) {
  ok <- file.copy(..., overwrite = overwrite)
  if (any(!ok)) {
    stop("Error copying files")
  }
  ok
}

## Prepare params
args <- readRDS(Sys.getenv("ORDERLY_RUN_ARGS_PATH"))

parameters <- NULL
if (!is.null(args$parameters)) {
  parameters <- sprintf("%s=%s", names(args$parameters),
                        vapply(args$parameters, format, character(1)))
}

id_file <- tempfile()
cli_args <- c("--root", args$root,
          "run", args$name, "--print-log", "--id-file", id_file,
          if (!is.null(args$instance)) c("--instance", args$instance),
          parameters)

## Run report via CLI
## We don't need to capture stdout as orderly CLI interleaves stdout
## stderr for us
log_err <- tempfile()
px <- processx::process$new(orderly_bin, cli_args,
                            stdout = NULL, stderr = log_err)

## Might be worth killing px on function exit
id <- NA_character_
poll <- 0.1
while (px$is_alive()) {
  if (is.na(id)) {
    if (file.exists(id_file)) {
      id <- readlines_if_exists(id_file, NA_character_)
    }
  }
  Sys.sleep(poll)
}

ok <- px$get_exit_status() == 0L
base <- if (ok) path_archive else path_draft
p <- file.path(base(args$root), args$name, id)
if (file.exists(p)) {
  file_copy(log_err, file.path(p, "orderly.log"))
}

if (!ok) {
  stop(paste(readLines(log_err), collapse = "\n"))
}
