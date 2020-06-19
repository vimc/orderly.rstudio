context("run-addin")

test_that("can list orderly remotes", {
  path <- orderly::orderly_example("demo", run_demo = TRUE)
  withr::with_dir(path, {
    expect_equal(get_remote_choices(), NULL)
  })

  p <- file.path(path, "orderly_config.yml")
  writeLines(c(
    "remote:",
    "  science:",
    "    driver: montagu::montagu_orderlyweb_remote",
    "    args:",
    "      host: support.montagu.dide.ic.ac.uk",
    "      port: 11443",
    "      username: $MONTAGU_PORTAL_USERNAME",
    "      password: $MONTAGU_PORTAL_PASSWORD",
    "  production:",
    "    driver: montagu::montagu_orderlyweb_remote",
    "    args:",
    "      host: production.montagu.dide.ic.ac.uk"),
    p)
  withr::with_dir(path, {
    expect_equal(get_remote_choices(), c("science", "production"))
  })
})

test_that("can list configured instances", {
  path <- orderly::orderly_example("demo", run_demo = TRUE)
  withr::with_dir(path, {
    expect_equal(get_instance_choices(), NULL)
  })

  p <- file.path(path, "orderly_config.yml")
  writeLines(c(
    "database:",
    "  source:",
    "    driver: RSQLite::SQLite",
    "    args:",
    "      dbname: source.sqlite",
    "    instances:",
    "      staging:",
    "        dbname: staging.sqlite",
    "      production:",
    "        dbname: production.sqlite"),
    p)
  withr::with_dir(path, {
    expect_equal(get_instance_choices(), c("staging", "production"))
  })

  p <- file.path(path, "orderly_config.yml")
  writeLines(c(
    "database:",
    "  source:",
    "    driver: RSQLite::SQLite",
    "    args:",
    "      dbname: source.sqlite",
    "    instances:",
    "      staging:",
    "        dbname: staging.sqlite",
    "      production:",
    "        dbname: production.sqlite",
    "  annex:",
    "    driver: RSQLite::SQLite",
    "    args:",
    "      dbname: annex.sqlite"),
    p)
  withr::with_dir(path, {
    expect_equal(get_instance_choices(), c("staging", "production"))
  })
})

test_that("can list parameters for a report", {
  path <- orderly::orderly_example("demo", run_demo = TRUE)
  withr::with_dir(path, {
    expect_equal(get_report_params("minimal"), NULL)
    expect_equal(get_report_params("other"), list(nmin = NULL))
  })

  p <- file.path(path, "src", "minimal", "orderly.yml")
  writeLines(c(
    "data:",
    "  dat:",
    "    query: SELECT name, number FROM thing",
    "script: script.R",
    "parameters:",
    "  param1:",
    "    default: 4",
    "  param2:",
    "    default: test",
    "  param3: ~",
    "artefacts:",
    "  staticgraph:",
    "    description: A graph of things",
    "    filenames: mygraph.png",
    "author: Researcher McResearcherface",
    "requester: Funder McFunderface",
    "comment: This is a comment"),
    p)
  withr::with_dir(path, {
    expect_equal(get_report_params("minimal"), list(
      param1 = list(
        default = 4),
      param2 = list(
        default = "test"),
      param3 = NULL
    ))
  })
})

test_that("can parse params from inputs", {
  inputs <- list(
    param_nmin = "213",
    param_two = "test",
    demo = "other_thing"
  )
  expect_equal(get_params(inputs),
               list(nmin = "213",
                    two = "test"))

  expect_equal(get_params(list(no_params = "test")), NULL)
})

test_that("can capture messages and output", {
  sink_output_no <- sink.number("output")
  sink_message_no <- sink.number("message")

  test_func <- function() {
    print("test")
    message("test message")
    "output"
  }
  x <- capture(test_func())
  expect_true("[1] \"test\"" %in% x)
  expect_true("[1] \"output\"" %in% x)
  ## "test message" should also be in x but testthat captures messages too
  ## so this is missing when running the whole test suite but stepping
  ## through this line by line it will be included.
  ## I can't face trying to battle testthat for message capturing precedence
  expect_equal(sink.number("output"), sink_output_no)
  expect_equal(sink.number("message"), sink_message_no)

  test_func <- function() {
    stop("error")
  }
  expect_error(capture(test_func()), "error")
  expect_equal(sink.number("output"), sink_output_no)
  expect_equal(sink.number("message"), sink_message_no)
})
