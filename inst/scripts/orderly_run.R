## This script is designed to be run as an RStudio job
## see orderly_run_session.R which sets up the run
## RStudio jobs cannot be parameterised
## https://github.com/rstudio/rstudio/issues/4176
## so to be able to parameterise the report run we need to save out the
## params we want to use to some file during the setup then read
## them from file when running the script.
args <- readRDS(Sys.getenv("ORDERLY_RUN_ARGS_PATH"))

orderly:::orderly_run_internal(name = args[["name"]],
                               parameters = args[["parameters"]],
                               envir = args[["envir"]],
                               root = args[["root"]],
                               locate = args[["locate"]],
                               message = args[["message"]],
                               instance = args[["instance"]],
                               use_draft = args[["use_draft"]],
                               remote = args[["remote"]],
                               tags = args[["tags"]],
                               commit = args[["commit"]])
