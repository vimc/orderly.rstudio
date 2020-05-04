context("start-addin")

test_that("can list reports", {
  dir <- orderly::orderly_example("demo", run_demo = TRUE)
  reports <- withr::with_dir(dir, list_reports())
  expect_equal(colnames(reports), c("report", "path", "modified"))
  expect_true(all(file.exists(reports$path)))
  expect_equal(reports$report[1], "changelog")
})
