## Prepare params
args <- readRDS(Sys.getenv("ORDERLY_RUN_ARGS_PATH"))

orderly:::orderly_run_internal(name = args[["name"]],
                               parameters = args[["parameters"]],
                               envir = args[["envir"]], root = args[["root"]],
                               locate = args[["locate"]],
                               message = args[["message"]],
                               instance = args[["instance"]],
                               use_draft = args[["use_draft"]],
                               remote = args[["remote"]], tags = args[["tags"]],
                               commit = args[["commit"]])
