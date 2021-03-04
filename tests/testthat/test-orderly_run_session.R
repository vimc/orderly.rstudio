context("orderly_run_session")

test_that("run report", {
  skip_if_not_rstudio()
  path <- orderly_prepare_orderly_example("demo")
  orderly_run_session("other", parameters = list(nmin = 0.1),
                      instance = NULL, root = path)
  testthat::try_again(5, {
    Sys.sleep(1)
    reports <- list.files(file.path(path, "draft", "other"),
                          full.names = TRUE)
    expect_length(reports, 1)
    expect_true(file.exists(file.path(reports, "orderly_run.rds")))
  })
})

test_that("run report", {
  path <- orderly_prepare_orderly_example("demo")
  run <- function(script) {
    processx::process$new("Rscript", script)
  }
  mockery::stub(orderly_run_session, "rstudioapi::jobRunScript", run)
  orderly_run_session("other", parameters = list(nmin = 0.1),
                      instance = NULL, root = path)
  testthat::try_again(5, {
    Sys.sleep(1)
    reports <- list.files(file.path(path, "draft", "other"),
                          full.names = TRUE)
    expect_length(reports, 1)
    expect_true(file.exists(file.path(reports, "orderly_run.rds")))
  })
})

test_that("run report and commit", {
  path <- orderly_prepare_orderly_example("demo")
  run <- function(script) {
    processx::process$new("Rscript", script)
  }
  mockery::stub(orderly_run_session, "rstudioapi::jobRunScript", run)
  orderly_run_session("other", parameters = list(nmin = 0.1),
                      instance = NULL, root = path, commit = TRUE)
  testthat::try_again(5, {
    Sys.sleep(1)
    reports <- list.files(file.path(path, "archive", "other"),
                          full.names = TRUE)
    expect_length(reports, 1)
    expect_true(file.exists(file.path(reports, "orderly_run.rds")))
  })
})

test_that("run failing report", {
  path <- orderly_prepare_orderly_example("demo")
  append_lines('stop("some error")',
               file.path(path, "src", "minimal", "script.R"))
  run <- function(script) {
    processx::process$new("Rscript", script)
  }
  mockery::stub(orderly_run_session, "rstudioapi::jobRunScript", run)
  orderly_run_session("minimal", parameters = NULL,
                      instance = NULL, root = path)
  testthat::try_again(5, {
    Sys.sleep(1)
    reports <- list.files(file.path(path, "draft", "minimal"),
                          full.names = TRUE)
    expect_length(reports, 1)
    expect_true(file.exists(file.path(reports, "orderly_fail.rds")))
  })
})

test_that("args are passed to run script", {
  mock_run_script <- mockery::mock(invisible(TRUE), cycle = TRUE)
  mock_save_rds <- mockery::mock(invisible(TRUE), cycle = TRUE)
  with_mock("rstudioapi::jobRunScript" = mock_run_script,
            "saveRDS" = mock_save_rds, {
    orderly_run_session("name", parameters = NULL, envir = "new env",
                        root = "root", locate = TRUE, message = "msg",
                        instance = "production", use_draft = TRUE,
                        remote = "science", tags = c("1", "2"))
  })
  mockery::expect_called(mock_save_rds, 1)
  args <- mockery::mock_args(mock_save_rds)
  params <- args[[1]][[1]]
  expect_equal(params$name, "name")
  expect_null(params$parameters)
  expect_equal(params$envir, "new env")
  expect_equal(params$root, "root")
  expect_true(params$locate)
  expect_equal(params$message, "msg")
  expect_equal(params$instance, "production")
  expect_true(params$use_draft)
  expect_equal(params$remote, "science")
  expect_equal(params$tags, c("1", "2"))
})
