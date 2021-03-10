#' Run an orderly report in separate session.
#'
#' This will run an orderly report using RStudio jobs. See
#' \code{\link[orderly]{orderly_run}} for details. This will run the
#' report async i.e. it won't block your RStudio terminal. This means
#' that it returns no info about success of job run - it only tells us
#' the job has started.
#'
#' @inheritParams orderly::orderly_run
#' @param commit If TRUE then report will be committed to archive after running
#'
#' @return Invisible return, called for side effects
#' @export
orderly_run_session <- function(name = NULL, parameters = NULL, envir = NULL,
                                root = NULL, locate = TRUE,
                                message = NULL, instance = NULL,
                                use_draft = FALSE, remote = NULL,
                                tags = NULL, commit = FALSE) {
  ## Setup params rds
  run_args <- list(
    name = name,
    parameters = parameters,
    envir = envir,
    root = root,
    locate = locate,
    message = message,
    instance = instance,
    use_draft = use_draft,
    remote = remote,
    tags = tags,
    commit = commit
  )
  args_path <- tempfile()
  ## RStudio job cannot take parameters so we save out params
  ## as an RDS which the script can read
  saveRDS(run_args, args_path)
  script_path <- orderly_rstudio_file("scripts/orderly_run.R")
  withr::with_envvar(c("ORDERLY_RUN_ARGS_PATH" = args_path), {
    rstudioapi::jobRunScript(script_path, workingDir = ".")
  })
  invisible(TRUE)
}
