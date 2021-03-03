orderly_run_session <- function(name, parameters, instance, root) {
  ## Setup params rds
  run_args <- list(
    root = root,
    name = name,
    parameters = parameters,
    instance = instance
  )
  args_path <- tempfile()
  saveRDS(run_args, args_path)
  script_path <- system_file("scripts/orderly_run.R")
  withr::with_envvar(c("ORDERLY_RUN_ARGS_PATH" = args_path), {
    rstudioapi::jobRunScript(script_path, encoding = "UTF-8",
                             exportEnv = "output_env")
  })
  ## deal with output
  get("id", output_env)
}
