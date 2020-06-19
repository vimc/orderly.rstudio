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
