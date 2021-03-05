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
  saveRDS(run_args, args_path)
  script_path <- orderly_rstudio_file("scripts/orderly_run.R")
  withr::with_envvar(c("ORDERLY_RUN_ARGS_PATH" = args_path), {
    rstudioapi::jobRunScript(script_path)
  })
}
