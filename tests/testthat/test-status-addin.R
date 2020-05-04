context("status-addin")

test_that("can get status", {
  dir <- orderly::orderly_example("demo", run_demo = TRUE)
  status <- withr::with_dir(file.path(dir, "src/use_dependency"), get_status())
  expect_equal(colnames(status),
               c("filename", "type", "present", "derived", "colour"))
  expect_true(all(status$colour %in% get_colours()))
  expect_true(all(grepl("fa", status$present)))
  expect_true(all(grepl("fa", status$derived)))
})
