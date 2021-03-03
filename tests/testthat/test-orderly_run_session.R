context("orderly_run_session")

test_that("run report", {
  path <- orderly_prepare_orderly_example("demo")
  id <- orderly_run_session("other", parameters = list(nmin = 0.1),
                            instance = NULL, root = path)
})
