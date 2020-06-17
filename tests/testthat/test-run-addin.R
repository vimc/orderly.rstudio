context("run-addin")

test_that("can list orderly remotes", {
  dir <- orderly::orderly_example("demo", run_demo = TRUE)
  withr::with_dir(dir, {
    expect_equal(get_remote_choices(), NULL)
  })

  p <- file.path(dir, "orderly_config.yml")
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
  withr::with_dir(dir, {
    expect_equal(get_remote_choices(), c("science", "production"))
  })
})

test_that("can list configured instances", {
  dir <- orderly::orderly_example("demo", run_demo = TRUE)
  withr::with_dir(dir, {
    expect_equal(get_instance_choices(), NULL)
  })

  p <- file.path(dir, "orderly_config.yml")
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
  withr::with_dir(dir, {
    expect_equal(get_instance_choices(), c("staging", "production"))
  })

  p <- file.path(dir, "orderly_config.yml")
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
  withr::with_dir(dir, {
    expect_equal(get_instance_choices(), c("staging", "production"))
  })
})
